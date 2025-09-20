--!strict

-- FIXME: we can probably remove this file now that we have the custom unparser

local libluau = require("@lute/luau")

local function getLeadingTriviaExpr(expr: libluau.AstExpr): { libluau.Trivia }
    if expr.tag == "local" then
        return expr.token.leadingTrivia
    elseif expr.tag == "index" then
        return getLeadingTriviaExpr(expr.expression)
    elseif expr.tag == "group" then
        return expr.openParens.leadingTrivia
    end

    error("unhandled expr tag: " .. expr.tag)
end
local function getLeadingTriviaStat(stat: libluau.AstStat): { libluau.Trivia }
    if stat.tag == "block" then
        return getLeadingTriviaStat(assert(stat.statements[1]))
    elseif stat.tag == "while" then
        return stat.whileKeyword.leadingTrivia
    elseif stat.tag == "for" then
        return stat.forKeyword.leadingTrivia
    elseif stat.tag == "assign" then
        return getLeadingTriviaExpr(stat.variables[1].node)
    elseif stat.tag == "local" then
        return stat.localKeyword.leadingTrivia
    elseif stat.tag == "repeat" then
        return stat.repeatKeyword.leadingTrivia
    elseif stat.tag == "return" then
        return stat.returnKeyword.leadingTrivia
    elseif stat.tag == "conditional" then
        return stat.ifKeyword.leadingTrivia
    end

    error("unhandled stat tag: " .. stat.tag)
end

local function replaceLeadingTriviaExpr(expr: libluau.AstExpr, trivia: { libluau.Trivia })
    if expr.tag == "local" then
        expr.token.leadingTrivia = trivia
        return
    elseif expr.tag == "index" then
        replaceLeadingTriviaExpr(expr.expression, trivia)
        return
    elseif expr.tag == "group" then
        expr.openParens.leadingTrivia = trivia
        return
    end

    error("unhandled expr tag: " .. expr.tag)
end
local function replaceLeadingTriviaStat(statement: libluau.AstStat, trivia: { libluau.Trivia })
    if statement.tag == "assign" then
        replaceLeadingTriviaExpr(statement.variables[1].node, trivia)
        return
    elseif statement.tag == "return" then
        statement.returnKeyword.leadingTrivia = trivia
        return
    elseif statement.tag == "local" then
        statement.localKeyword.leadingTrivia = trivia
        return
    elseif statement.tag == "block" then
        replaceLeadingTriviaStat(assert(statement.statements[1]), trivia)
        return
    elseif statement.tag == "conditional" then
        statement.ifKeyword.leadingTrivia = trivia
        return
    elseif statement.tag == "while" then
        statement.whileKeyword.leadingTrivia = trivia
        return
    elseif statement.tag == "for" then
        statement.forKeyword.leadingTrivia = trivia
        return
    end

    error("unhandled stat tag: " .. statement.tag)
end

return {
    getLeadingTriviaExpr = getLeadingTriviaExpr,
    getLeadingTriviaStat = getLeadingTriviaStat,

    replaceLeadingTriviaExpr = replaceLeadingTriviaExpr,
    replaceLeadingTriviaStat = replaceLeadingTriviaStat
}
