--!strict

export type Scope = {
    scope_id: number,
    parent_scope_id: number?,
    value_map: { [string]: ScopeValue },

    hasValue: ( Scope, string, boolean? ) -> boolean,
    setValue: ( Scope, string, ScopeValue ) -> (),
    addValue: ( Scope, string, ScopeValue ) -> (),
    getValue: ( Scope, string, boolean? ) -> ScopeValue?,
    removeValue: ( Scope, string ) -> ()
}
-- export type ScopeValue = {
--     tag: "string",
--     value: string
-- } | {
--     tag: "number",
--     value: number
-- } | {
--     tag: "unknown"
-- }
local libluau = require("@lute/luau")
export type ScopeValue = libluau.AstExpr

local global_scopeid_counter = 0
local id_scope_map: { [number]: Scope } = {}

local Scope = {}
Scope.__index = Scope

function Scope.new(parent_scope_id: number?): Scope
    local this_scope_id = global_scopeid_counter
    local this = {
        scope_id = this_scope_id,
        parent_scope_id = parent_scope_id,
        value_map = {}
    }
    global_scopeid_counter += 1

    local scope: Scope = setmetatable(this, Scope) :: any
    id_scope_map[this_scope_id] = scope

    return scope
end

function Scope.hasValue(self: Scope, value_name: string, recursive: boolean?): boolean
    recursive = if type(recursive) == "nil" then true else recursive

    if type(self.value_map[value_name]) ~= "nil" then
        return true
    end

    if recursive and self.parent_scope_id then
        return id_scope_map[self.parent_scope_id]:hasValue(value_name, true)
    end

    return false
end

function Scope.setValue(self: Scope, value_name: string, value: ScopeValue)
    self.value_map[value_name] = value
end
function Scope.addValue(self: Scope, value_name: string, value: ScopeValue)
    if self:hasValue(value_name) then
        error("value '" .. value_name .. "' already exists in scope", 2)
    end

    self:setValue(value_name, value)
end

function Scope.getValue(self: Scope, value_name: string, recursive: boolean?): ScopeValue?
    recursive = if type(recursive) == "nil" then true else recursive

    if not self:hasValue(value_name, recursive) then
        return nil
    end

    return self.value_map[value_name] or
        if recursive and self.parent_scope_id then
            id_scope_map[self.parent_scope_id]:getValue(value_name, true)
        else nil
end

function Scope.removeValue(self: Scope, value_name: string)
    if not self:hasValue(value_name, false) then
        error("value '" .. value_name .. "' does not exist in scope", 2)
    end

    self.value_map[value_name] = nil
end

return Scope
