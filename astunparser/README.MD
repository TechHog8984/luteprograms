# astunparser

a library to turn a Luau AST statements into source code

example:
```luau
local astparser = require("@std/syntax/parser")
local astunparser = require("@astunparser")

local root = astparser.parse("local a = 1; print(a)")

print(astunparser.unparseRoot(root))
--[[ output:
local a = 1
print(a)

]]
```
