--!strict

local libluau = require("@lute/luau")
local basic_ast_manipulation = require("@astmanipulation/basic")

export type VarCondition = {
    op: "~=" | "==" | "<" | "<=" | ">" | ">=" | "and" | "or",
    left: VarConditionValue,
    right: VarConditionValue,

    evaluate: ( VarCondition, number ) -> boolean?,
    getName: ( VarCondition ) -> string?,
    getNumber: ( VarCondition ) -> number?,
}
export type VarConditionValue = {
    tag: "local",
    text: string
} | {
    tag: "number",
    value: number
} | {
    tag: "condition",
    value: VarCondition
}

local VarCondition = {}
VarCondition.__index = VarCondition

function VarCondition.new(op: "~=" | "==" | "<" | "<=" | ">" | ">=" | "and" | "or", left: VarConditionValue, right: VarConditionValue): VarCondition
    local this = {
        op = op,
        left = left,
        right = right
    }

    return setmetatable(this, VarCondition) :: any
end

function VarCondition.evaluate(self: VarCondition, target: number): boolean?
    if self.op == "~=" or self.op == "==" or self.op == "<" or self.op == "<=" or
        self.op == ">" or self.op == ">="
    then
        local left: number
        local right: number

        if self.left.tag == "local" then
            left = target
        elseif self.right.tag == "local" then
            right = target
        end

        if self.left.tag == "number" then
            left = self.left.value
        elseif self.right.tag == "number" then
            right = self.right.value
        end

        assert(left and right)

        if self.op == "~=" then
            return left ~= right
        elseif self.op == "==" then
            return left == right
        elseif self.op == "<" then
            return left < right
        elseif self.op == "<=" then
            return left <= right
        elseif self.op == ">" then
            return left > right
        elseif self.op == ">=" then
            return left >= right
        end

        error("unreachable")
    elseif self.op == "and" or self.op == "or" then
        local left = true
        local right = true

        if self.left.tag == "condition" then
            left = assert(self.left.value:evaluate(target))
        end
        if self.right.tag == "condition" then
            right = assert(self.right.value:evaluate(target))
        end

        if self.op == "and" then
            return left and right
        elseif self.op == "or" then
            return left or right
        end

        error("unreachable")
    end

    return nil
end
function VarCondition.getName(self: VarCondition): string?
    if self.left.tag == "local" then
        return self.left.text
    elseif self.right.tag == "local" then
        return self.right.text
    end

    if self.left.tag == "condition" then
        local name = self.left.value:getName()
        if name then return name end
    elseif self.right.tag == "condition" then
        local name = self.right.value:getName()
        if name then return name end
    end

    return nil
end
function VarCondition.getNumber(self: VarCondition): number?
    if self.left.tag == "number" then
        return self.left.value
    elseif self.right.tag == "number" then
        return self.right.value
    end

    if self.left.tag == "condition" then
        local number = self.left.value:getNumber()
        if number then return number end
    elseif self.right.tag == "condition" then
        local number = self.right.value:getNumber()
        if number then return number end
    end

    return nil
end

local function getVarConditionValue(expression: libluau.AstExpr, target_variable: string?): VarConditionValue?
    expression = basic_ast_manipulation.getInmostExpression(expression)

    local number = basic_ast_manipulation.getNumber(expression)
    if number then
        return { tag = "number", value = number }
    elseif expression.tag == "local" then
        local text = expression["local"].name.text
        if target_variable and text ~= target_variable then return nil end

        return { tag = "local", text = text }
    elseif expression.tag == "binary" then
        local op = expression.operator.text

        local left = getVarConditionValue(expression.lhsoperand, target_variable)
        if not left then return nil end
        local right = getVarConditionValue(expression.rhsoperand, target_variable)
        if not right then return nil end

        if left.tag == "local" and right.tag == "local" then
            return nil
        end

        if op == "~=" or op == "==" or op == "<" or op == "<=" or
            op == ">" or op == ">=" or op == "and" or op == "or"
        then
            return { tag = "condition", value = VarCondition.new(op, left, right) }
        else
            return nil
        end
    end

    return nil
end
local function getVarCondition(expression: libluau.AstExpr, target_variable: string?): VarCondition?
    local value = getVarConditionValue(expression, target_variable)
    if not value then
        return nil
    end

    if value.tag ~= "condition" then
        return nil
    end

    return value.value
end

return getVarCondition
