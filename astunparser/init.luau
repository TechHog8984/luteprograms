--!strict
--!optimize 2

local libluau = require("@lute/luau")
local astmanipulation = require("@astmanipulation")

local replacement_map_expr: { [libluau.AstExpr | libluau.AstStat]: libluau.AstExpr } = {}
local replacement_map_stat: { [libluau.AstExpr | libluau.AstStat]: libluau.AstStat } = {}
local no_do_end_map: { [libluau.AstStat]: boolean } = {}

type Unparser = {
    _characters: { string },
    _indent: string,

    _last_insertion_was_newline: boolean,
    _at_beginning_of_block: boolean,
    _in_table: boolean,
    _next_block_has_do_end: boolean,

    string: ( Unparser, string ) -> (),
    characters: ( Unparser, { string }) -> (),

    space: ( Unparser ) -> (),
    newline: ( Unparser ) -> (),
    indent: ( Unparser ) -> (),

    startIndent: ( Unparser ) -> (),
    endIndent: ( Unparser ) -> (),

    removeNewline: ( Unparser ) -> (),

    unparseToken: ( Unparser, libluau.Token<any> ) -> (),

    unparsePunctuatedExpr: ( Unparser, libluau.Punctuated<libluau.AstExpr, any> ) -> (),
    unparsePunctuatedToken: ( Unparser, libluau.Punctuated<libluau.Token, any> ) -> (),
    unparsePunctuatedLocal: ( Unparser, libluau.Punctuated<libluau.AstLocal, any> ) -> (),

    unparseExpr: ( Unparser, libluau.AstExpr ) -> (),
    unparseStat: ( Unparser, libluau.AstStat ) -> (),

    unparseFunctionBody: ( Unparser, libluau.AstFunctionBody ) -> (),
    unparseElseIf: ( Unparser, libluau.AstStatElseIf ) -> (),

    unparseRoot: ( Unparser, libluau.AstStat ) -> string,

    _toString: ( Unparser ) -> string
}

local Unparser = {}
Unparser.__index = Unparser

function Unparser.new(): Unparser
    local this = {
        _characters = {},
        _indent = "",
        _last_insertion_was_newline = false,
        _at_beginning_of_block = false,
        _in_table = false,
        _next_block_has_do_end = false
    }

    return setmetatable(this, Unparser) :: any
end

function Unparser.string(self: Unparser, str: string)
    self._last_insertion_was_newline = false
    self._at_beginning_of_block = false
    for ch in str:gmatch('.') do
        self._characters[#self._characters + 1] = ch
    end
end
function Unparser.characters(self: Unparser, characters: { string })
    self._last_insertion_was_newline = false
    self._at_beginning_of_block = false
    local start = #self._characters
    for i, v in characters do
        self._characters[start + i] = v
    end
end

function Unparser.space(self: Unparser)
    self:string(" ")
end
function Unparser.newline(self: Unparser)
    self:string("\n")
    self:indent()
    self._last_insertion_was_newline = true
end
function Unparser.indent(self: Unparser)
    self:string(self._indent)
end

function Unparser.startIndent(self: Unparser)
    self._indent ..= '    '
    self:newline()
end
function Unparser.endIndent(self: Unparser)
    self._indent = self._indent:sub(1, -5)
    self:newline()
end

function Unparser.removeNewline(self: Unparser)
    -- self._result = (self._result:gsub("\n +$", ""))
    local index = -1
    for i = #self._characters, 1, -1 do
        if self._characters[i] == ' ' then
            index = i
        else
            break
        end
    end
    if index == -1 then return end

    if self._characters[index - 1] == '\n' then
        index -= 1
    end

    for i = index, #self._characters do
        self._characters[i] = nil
    end
end

function Unparser.unparseToken(self: Unparser, token: libluau.Token<any>)
    self:string(token.text)
end

function Unparser.unparsePunctuatedExpr(self: Unparser, punctuated: libluau.Punctuated<libluau.AstExpr, any>)
    for _, expr in punctuated do
        self:unparseExpr(expr.node)
        local sep = expr.separator
        if sep then
            self:unparseToken(sep)
            self:space()
        end
    end
end
function Unparser.unparsePunctuatedToken(self: Unparser, punctuated: libluau.Punctuated<libluau.Token, any>)
    for _, token in punctuated do
        self:unparseToken(token.node)
        local sep = token.separator
        if sep then
            self:unparseToken(sep)
            self:space()
        end
    end
end
function Unparser.unparsePunctuatedLocal(self: Unparser, punctuated: libluau.Punctuated<libluau.AstLocal, any>)
    for _, l in punctuated do
        self:unparseToken(l.node.name)
        local sep = l.separator
        if sep then
            self:unparseToken(sep)
            self:space()
        end
    end
end

local quotestyle_map = {
    single = '\'',
    double = '"',
    interp = '`'
}

function Unparser.unparseExpr(self: Unparser, the_expr: libluau.AstExpr)
    do
        local expr = replacement_map_expr[the_expr]
        if expr then
            the_expr = expr
        else
            local stat = replacement_map_stat[the_expr]
            if stat then
                return self:unparseStat(stat)
            end
        end
    end

    if the_expr.tag == "group" then
        if self._last_insertion_was_newline and not self._at_beginning_of_block and not self._in_table then
            self:string(';')
        end
        self:unparseToken(the_expr.openParens)
        self:unparseExpr(the_expr.expression)
        self:unparseToken(the_expr.closeParens)
    elseif the_expr.tag == "nil" or the_expr.tag == "boolean" or
        the_expr.tag == "number" or the_expr.tag == "vararg"
    then
        self:unparseToken(the_expr)
    elseif the_expr.tag == "string" then
        local isblock = the_expr.quoteStyle == "block"
        if isblock then
            self:string('[')
            for i = 1, the_expr.blockDepth do
                self:string('=')
            end
            self:string('[')
        else
            self:string(quotestyle_map[the_expr.quoteStyle])
        end

        self:unparseToken(the_expr)

        if isblock then
            self:string(']')
            for i = 1, the_expr.blockDepth do
                self:string('=')
            end
            self:string(']')
        else
            self:string(quotestyle_map[the_expr.quoteStyle])
        end
    elseif the_expr.tag == "local" then
        self:unparseToken(the_expr.token)
    elseif the_expr.tag == "global" then
        self:unparseToken(the_expr.name)
    elseif the_expr.tag == "call" then
        self:unparseExpr(the_expr.func)

        if the_expr.openParens then
            self:unparseToken(the_expr.openParens)
        end

        self:unparsePunctuatedExpr(the_expr.arguments)

        if the_expr.closeParens then
            self:unparseToken(the_expr.closeParens)
        end
    elseif the_expr.tag == "indexname" then
        self:unparseExpr(the_expr.expression)
        self:unparseToken(the_expr.accessor)
        self:unparseToken(the_expr.index)
    elseif the_expr.tag == "index" then
        self:unparseExpr(the_expr.expression)
        self:unparseToken(the_expr.openBrackets)
        self:unparseExpr(the_expr.index)
        self:unparseToken(the_expr.closeBrackets)
    elseif the_expr.tag == "function" then
        self:unparseToken(the_expr.functionKeyword)
        self:unparseFunctionBody(the_expr.body)
    elseif the_expr.tag == "table" then
        self:unparseToken(the_expr.openBrace)

        -- Run up to two passes; if the first pass's end result exceeds 100 characters, run the second pass.
        -- First pass doesnt use new lines; second pass does.

        local subunparser = Unparser.new()
        subunparser._in_table = true
        for i = 1, 2 do
            subunparser._characters = {}
            subunparser._indent = self._indent

            if i == 2 then
                subunparser:startIndent()
            end

            local at_limit = false
            local entry_count = #the_expr.entries
            for entry_i, entry in the_expr.entries do
                if entry.kind == "list" then
                    subunparser:unparseExpr(entry.value)
                elseif entry.kind == "record" then
                    subunparser:unparseToken(entry.key)

                    subunparser:space()
                    subunparser:unparseToken(entry.equals)
                    subunparser:space()

                    subunparser:unparseExpr(entry.value)
                else
                    subunparser:unparseToken(entry.indexerOpen)
                    subunparser:unparseExpr(entry.key)
                    subunparser:unparseToken(entry.indexerClose)

                    subunparser:space()
                    subunparser:unparseToken(entry.equals)
                    subunparser:space()

                    subunparser:unparseExpr(entry.value)
                end

                local sep = entry.separator
                if sep then
                    subunparser:unparseToken(sep)
                end
                if entry_i ~= entry_count then
                    if i == 1 then
                        subunparser:space()
                    else
                        subunparser:newline()
                    end
                end

                if #subunparser._characters > 100 and i == 1 then
                    at_limit = true
                    break
                end
            end
            if at_limit then continue end

            if i == 2 then
                subunparser:endIndent()
            end

            self:characters(subunparser._characters)

            break
        end

        self:unparseToken(the_expr.closeBrace)
    elseif the_expr.tag == "unary" then
        self:unparseToken(the_expr.operator)
        if the_expr.operator.text == "not" then
            self:space()
        end

        self:unparseExpr(the_expr.operand)
    elseif the_expr.tag == "binary" then
        self:unparseExpr(the_expr.lhsoperand)
        self:space()
        self:unparseToken(the_expr.operator)
        self:space()
        self:unparseExpr(the_expr.rhsoperand)
    elseif the_expr.tag == "interpolatedstring" then
        self:string('`')

        for index, str in the_expr.strings do
            self:unparseToken(str)
            local expr = the_expr.expressions[index]
            if expr then
                self:string('{')
                self:unparseExpr(expr)
                self:string('}')
            end
        end

        self:string('`')
    elseif the_expr.tag == "conditional" then
        self:unparseToken(the_expr.ifKeyword)
        self:space()
        self:unparseExpr(the_expr.condition)
        self:space()
        self:unparseToken(the_expr.thenKeyword)
        self:space()
        self:unparseExpr(the_expr.consequent)

        for _, v in the_expr.elseifs do
            self:space()

            self:unparseToken(v.elseifKeyword)
            self:space()
            self:unparseExpr(v.condition)
            self:space()
            self:unparseToken(v.thenKeyword)
            self:space()
            self:unparseExpr(v.consequent)
        end

        self:unparseToken(the_expr.elseKeyword)
        self:space()
        self:unparseExpr(the_expr.antecedent)
    else
        assert("UNHANDLED EXPR TAG " .. the_expr.tag)
    end
end
function Unparser.unparseStat(self: Unparser, the_stat: libluau.AstStat)
    do
        local stat = replacement_map_stat[the_stat]
        if stat then
            the_stat = stat
        else
            local expr = replacement_map_expr[the_stat]
            if expr then
                return self:unparseExpr(expr)
            end
        end
    end

    local has_do_end = self._next_block_has_do_end
    self._next_block_has_do_end = true
    if the_stat.tag == "block" then
        if no_do_end_map[the_stat] then
            local last = the_stat.statements[#the_stat.statements]
            if last and not (last.tag == "return" or last.tag == "continue" or last.tag == "break") then
                has_do_end = false
            end
        end

        if has_do_end then
            self:string("do")
            self:startIndent()
        end

        if next(the_stat.statements) then
            self._at_beginning_of_block = true
            for _, stat in the_stat.statements do
                self:unparseStat(stat)
                self:newline()
            end
            self._at_beginning_of_block = false
            self:removeNewline()
        else
            self:string("-- empty block")
        end

        if has_do_end then
            self:endIndent()
            self:string("end")
        end
    elseif the_stat.tag == "conditional" then
        local condition = the_stat.condition
        local consequent = the_stat.consequent
        local antecedent = the_stat.antecedent

        -- NOTE: duplicate code #0
        if #consequent.statements == 0 and antecedent then
            local inversed_condition = astmanipulation.basic.flipExpression(
                condition,
                true
            )
            if inversed_condition then
                condition = inversed_condition
                consequent = antecedent
                antecedent = nil
            end
        end

        self:unparseToken(the_stat.ifKeyword)
        self:space()
        self:unparseExpr(astmanipulation.basic.getInmostExpression(
            condition
        ))
        self:space()
        self:unparseToken(the_stat.thenKeyword)

        self:startIndent()
        self._next_block_has_do_end = false
        self:unparseStat(consequent)
        self:endIndent()

        if #the_stat.elseifs == 1 then
            local elif = the_stat.elseifs[1]
            local old_condition = elif.condition
            local old_consequent = elif.consequent

            local new_condition = old_condition
            local new_consequent = old_consequent

            -- NOTE: duplicate code #0
            if #new_consequent.statements == 0 and antecedent then
                local inversed_condition = astmanipulation.basic.flipExpression(
                    new_condition,
                    true
                )
                if inversed_condition then
                    new_condition = inversed_condition
                    new_consequent = antecedent
                    antecedent = nil
                end
            end

            elif.condition = new_condition
            elif.consequent = new_consequent

            self:unparseElseIf(elif)

            elif.condition = old_condition
            elif.consequent = old_consequent
        else
            for _, v in the_stat.elseifs do
                self:unparseElseIf(v)
            end
        end

        if the_stat.elseKeyword and antecedent then
            self:unparseToken(the_stat.elseKeyword)

            self:startIndent()
            self._next_block_has_do_end = false
            self:unparseStat(antecedent)
            self:endIndent()
        end

        self:unparseToken(the_stat.endKeyword)
    elseif the_stat.tag == "while" then
        self:unparseToken(the_stat.whileKeyword)
        self:space()
        self:unparseExpr(astmanipulation.basic.getInmostExpression(
            the_stat.condition
        ))
        self:space()
        self:unparseToken(the_stat.doKeyword)

        self:startIndent()
        self._next_block_has_do_end = false
        self:unparseStat(the_stat.body)
        self:endIndent()

        self:unparseToken(the_stat.endKeyword)
    elseif the_stat.tag == "repeat" then
        self:unparseToken(the_stat.repeatKeyword)

        self:startIndent()
        self._next_block_has_do_end = false
        self:unparseStat(the_stat.body)
        self:endIndent()

        self:unparseToken(the_stat.untilKeyword)
        self:space()
        self:unparseExpr(the_stat.condition)
    elseif the_stat.tag == "break" or the_stat.tag == "continue" then
        self:unparseToken(the_stat)
    elseif the_stat.tag == "return" then
        self:unparseToken(the_stat.returnKeyword)
        self:space()
        self:unparsePunctuatedExpr(the_stat.expressions)
    elseif the_stat.tag == "expression" then
        self:unparseExpr(the_stat.expression)
    elseif the_stat.tag == "local" then
        self:unparseToken(the_stat.localKeyword)
        self:space()
        self:unparsePunctuatedLocal(the_stat.variables)
        if the_stat.equals then
            self:space()
            self:unparseToken(the_stat.equals)
            self:space()
            self:unparsePunctuatedExpr(the_stat.values)
        end
    elseif the_stat.tag == "for" then
        self:unparseToken(the_stat.forKeyword)
        self:space()
        self:unparseToken(the_stat.variable.name)
        self:space()
        self:unparseToken(the_stat.equals)
        self:space()
        self:unparseExpr(the_stat.from)

        self:unparseToken(the_stat.toComma)
        self:space()
        self:unparseExpr(the_stat.to)

        if the_stat.stepComma and the_stat.step then
            self:unparseToken(the_stat.stepComma)
            self:space()
            self:unparseExpr(the_stat.step)
        end

        self:space()
        self:unparseToken(the_stat.doKeyword)

        self:startIndent()
        self._next_block_has_do_end = false
        self:unparseStat(the_stat.body)
        self:endIndent()
        self:unparseToken(the_stat.endKeyword)
    elseif the_stat.tag == "forin" then
        self:unparseToken(the_stat.forKeyword)
        self:space()
        self:unparsePunctuatedLocal(the_stat.variables)
        self:space()
        self:unparseToken(the_stat.inKeyword)
        self:space()
        self:unparsePunctuatedExpr(the_stat.values)
        self:space()
        self:unparseToken(the_stat.doKeyword)

        self:startIndent()
        self._next_block_has_do_end = false
        self:unparseStat(the_stat.body)
        self:endIndent()

        self:unparseToken(the_stat.endKeyword)
    elseif the_stat.tag == "assign" then
        self:unparsePunctuatedExpr(the_stat.variables)
        self:space()
        self:unparseToken(the_stat.equals)
        self:space()
        self:unparsePunctuatedExpr(the_stat.values)
    elseif the_stat.tag == "compoundassign" then
        self:unparseExpr(the_stat.variable)
        self:space()
        self:unparseToken(the_stat.operand)
        self:space()
        self:unparseExpr(the_stat.value)
    elseif the_stat.tag == "function" then
        self:unparseToken(the_stat.functionKeyword)
        self:space()
        self:unparseExpr(the_stat.name)
        self:unparseFunctionBody(the_stat.body)
    elseif the_stat.tag == "localfunction" then
        self:unparseToken(the_stat.localKeyword)
        self:space()
        self:unparseToken(the_stat.functionKeyword)
        self:space()
        self:unparseToken(the_stat.name.name)
        self:unparseFunctionBody(the_stat.body)
    else
        assert("UNHANDLED STAT TAG " .. the_stat.tag)
    end
end

function Unparser.unparseFunctionBody(self: Unparser, funcbody: libluau.AstFunctionBody)
    self:unparseToken(funcbody.openParens)
    self:unparsePunctuatedLocal(funcbody.parameters)
    if funcbody.vararg then
        self:unparseToken(funcbody.vararg)
    end
    self:unparseToken(funcbody.closeParens)

    self:startIndent()
    self._next_block_has_do_end = false
    self:unparseStat(funcbody.body)
    self:endIndent()

    self:unparseToken(funcbody.endKeyword)
end
function Unparser.unparseElseIf(self: Unparser, elif: libluau.AstStatElseIf)
    self:unparseToken(elif.elseifKeyword)
    self:space()
    self:unparseExpr(astmanipulation.basic.getInmostExpression(
        elif.condition
    ))
    self:space()
    self:unparseToken(elif.thenKeyword)

    self:startIndent()
    self._next_block_has_do_end = false
    self:unparseStat(elif.consequent)
    self:endIndent()
end

function Unparser.unparseRoot(self: Unparser, root: libluau.AstStat): string
    self:unparseStat(root)

    return self:_toString()
end

function Unparser._toString(self: Unparser): string
    return table.concat(self._characters)
end

-- public

local function unparseRoot(root: libluau.AstStat): string
    local unparser = Unparser.new()

    return unparser:unparseRoot(root)
end
local function unparseExpression(expr: libluau.AstExpr): string
    local unparser = Unparser.new()

    unparser:unparseExpr(expr)

    return unparser:_toString()
end

local function markReplacementExpr(node: libluau.AstExpr | libluau.AstStat, replacement: libluau.AstExpr)
    replacement_map_stat[node] = nil
    replacement_map_expr[node] = replacement
end
local function markReplacementStat(node: libluau.AstExpr | libluau.AstStat, replacement: libluau.AstStat)
    replacement_map_expr[node] = nil
    replacement_map_stat[node] = replacement
end
local function markNoDoEnd(stat: libluau.AstStat)
    no_do_end_map[stat] = true
end

return {
    unparseRoot = unparseRoot,
    unparseExpression = unparseExpression,
    markReplacementExpr = markReplacementExpr,
    markReplacementStat = markReplacementStat,
    markNoDoEnd = markNoDoEnd
}
