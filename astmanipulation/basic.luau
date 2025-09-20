--!strict

local libluau = require("@lute/luau")

local basic_ast_manipulation = {}

function basic_ast_manipulation.getInmostExpression(expression: libluau.AstExpr): libluau.AstExpr
    local inmost: libluau.AstExpr = expression
    while inmost.tag == "group" do
        inmost = inmost.expression
    end
    return inmost
end
function basic_ast_manipulation.getInmostStatement(statement: libluau.AstStat): libluau.AstStat
    local inmost: libluau.AstStat = statement
    while inmost.tag == "block" and #inmost.statements == 1 do
        inmost = inmost.statements[1]
    end
    return inmost
end

function basic_ast_manipulation.getNumber(expression: libluau.AstExpr): number?
    expression = basic_ast_manipulation.getInmostExpression(expression)
    if expression.tag == "number" then
        return expression.value
    end

    return nil
end

function basic_ast_manipulation.isTruthyExpression(expression: libluau.AstExpr): boolean?
    expression = basic_ast_manipulation.getInmostExpression(expression)
    if expression.tag == "boolean" then
        return expression.value
    end

    return nil
end

-- users of this function MUST NOTE that it doesn't deep clone!
function basic_ast_manipulation.flipExpression(expression: libluau.AstExpr, allow_simple_not: boolean?): libluau.AstExpr?
    if type(allow_simple_not) == "nil" then allow_simple_not = false end

    local inmost = basic_ast_manipulation.getInmostExpression(expression)
    if inmost.tag == "boolean" then
        local new: libluau.AstExprConstantBool = table.clone(inmost) :: any
        new.value = not new.value
        return new
    elseif inmost.tag == "unary" and inmost.operator.text == "not" then
        if inmost.operand.tag == "group" then
            local new: libluau.AstExprGroup = libluau.parseexpr("(1)") :: any
            new.expression = inmost.operand
            return new
        end
        return inmost.operand
    end

    if allow_simple_not then
        local new: libluau.AstExprUnary = libluau.parseexpr("not 1") :: any
        new.operand = expression
        return new
    end

    return nil
end

return basic_ast_manipulation
