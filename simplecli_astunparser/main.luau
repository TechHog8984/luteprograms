local unparser = require("@astunparser")
local input = require("@lute/fs").readfiletostring(select(2, ...))

local parsed = require("@std/syntax/parser").parse(input)

print(unparser.unparseRoot(parsed))
