--!strict
--!nolint LocalShadow

-- NOTE: this rewriter will directly replace fields in objects.
-- deep clone before rewriting if you want to avoid modifications.


local libluau = require("@lute/luau")

export type Rewriter = {
    visitBlock: (libluau.AstStatBlock) -> libluau.AstStatBlock,
    visitIf: (libluau.AstStatIf) -> libluau.AstStat,
    visitWhile: (libluau.AstStatWhile) -> libluau.AstStat,
    visitBreak: (libluau.AstStatBreak) -> libluau.AstStat,
    visitContinue: (libluau.AstStatContinue) -> libluau.AstStat,
    visitRepeat: (libluau.AstStatRepeat) -> libluau.AstStat,
    visitReturn: (libluau.AstStatReturn) -> libluau.AstStat,
    visitLocalDeclaration: (libluau.AstStatLocal) -> libluau.AstStat,
    visitFor: (libluau.AstStatFor) -> libluau.AstStat,
    visitForIn: (libluau.AstStatForIn) -> libluau.AstStat,
    visitAssign: (libluau.AstStatAssign) -> libluau.AstStat,
    visitCompoundAssign: (libluau.AstStatCompoundAssign) -> libluau.AstStat,
    visitFunction: (libluau.AstStatFunction) -> libluau.AstStat,
    visitLocalFunction: (libluau.AstStatLocalFunction) -> libluau.AstStat,
    visitStatExpression: (libluau.AstStatExpr) -> libluau.AstStat,
    visitTypeAlias: (libluau.AstStatTypeAlias) -> libluau.AstStat,
    visitStatTypeFunction: (libluau.AstStatTypeFunction) -> libluau.AstStat,

    visitLocalReference: (libluau.AstExprLocal) -> libluau.AstExpr,
    visitGlobal: (libluau.AstExprGlobal) -> libluau.AstExpr,
    visitCall: (libluau.AstExprCall) -> libluau.AstExpr,
    visitUnary: (libluau.AstExprUnary) -> libluau.AstExpr,
    visitBinary: (libluau.AstExprBinary) -> libluau.AstExpr,
    visitAnonymousFunction: (libluau.AstExprAnonymousFunction) -> libluau.AstExpr,
    visitTableItem: (libluau.AstExprTableItem) -> libluau.AstExprTableItem,
    visitTable: (libluau.AstExprTable) -> libluau.AstExpr,
    visitIndexName: (libluau.AstExprIndexName) -> libluau.AstExpr,
    visitIndexExpr: (libluau.AstExprIndexExpr) -> libluau.AstExpr,
    visitGroup: (libluau.AstExprGroup) -> libluau.AstExpr,
    visitInterpolatedString: (libluau.AstExprInterpString) -> libluau.AstExpr,
    visitTypeAssertion: (libluau.AstExprTypeAssertion) -> libluau.AstExpr,
    visitIfExpression: (libluau.AstExprIfElse) -> libluau.AstExpr,

    visitTypeReference: (libluau.AstTypeReference) -> libluau.AstType,
    visitTypeBoolean: (libluau.AstTypeSingletonBool) -> libluau.AstType,
    visitTypeString: (libluau.AstTypeSingletonString) -> libluau.AstType,
    visitTypeTypeof: (libluau.AstTypeTypeof) -> libluau.AstType,
    visitTypeGroup: (libluau.AstTypeGroup) -> libluau.AstType,
    visitTypeUnion: (libluau.AstTypeUnion) -> libluau.AstType,
    visitTypeIntersection: (libluau.AstTypeIntersection) -> libluau.AstType,
    visitTypeArray: (libluau.AstTypeArray) -> libluau.AstType,
    visitTypeTable: (libluau.AstTypeTable) -> libluau.AstType,
    visitTypeFunction: (libluau.AstTypeFunction) -> libluau.AstType,

    visitTypePackExplicit: (libluau.AstTypePackExplicit) -> libluau.AstTypePack,
    visitTypePackGeneric: (libluau.AstTypePackGeneric) -> libluau.AstTypePack,
    visitTypePackVariadic: (libluau.AstTypePackVariadic) -> libluau.AstTypePack,

    visitToken: (libluau.Token) -> libluau.Token,
    visitNil: (libluau.AstExprConstantNil) -> libluau.AstExpr,
    visitString: (libluau.AstExprConstantString) -> libluau.AstExpr,
    visitBoolean: (libluau.AstExprConstantBool) -> libluau.AstExpr,
    visitNumber: (libluau.AstExprConstantNumber) -> libluau.AstExpr,
    visitLocal: (libluau.AstLocal) -> libluau.AstLocal,
    visitVararg: (libluau.AstExprVarargs) -> libluau.AstExpr,
}

local function alwaysRewrite(...: any)
    return ...
end

local default_rewriter: Rewriter = {
    visitBlock = alwaysRewrite :: any,
    visitIf = alwaysRewrite :: any,
    visitWhile = alwaysRewrite :: any,
    visitBreak = alwaysRewrite :: any,
    visitContinue = alwaysRewrite :: any,
    visitRepeat = alwaysRewrite :: any,
    visitReturn = alwaysRewrite :: any,
    visitLocalDeclaration = alwaysRewrite :: any,
    visitFor = alwaysRewrite :: any,
    visitForIn = alwaysRewrite :: any,
    visitAssign = alwaysRewrite :: any,
    visitCompoundAssign = alwaysRewrite :: any,
    visitFunction = alwaysRewrite :: any,
    visitLocalFunction = alwaysRewrite :: any,
    visitStatExpression = alwaysRewrite :: any,
    visitTypeAlias = alwaysRewrite :: any,
    visitStatTypeFunction = alwaysRewrite :: any,

    visitLocalReference = alwaysRewrite :: any,
    visitGlobal = alwaysRewrite :: any,
    visitCall = alwaysRewrite :: any,
    visitUnary = alwaysRewrite :: any,
    visitBinary = alwaysRewrite :: any,
    visitAnonymousFunction = alwaysRewrite :: any,
    visitTableItem = alwaysRewrite :: any,
    visitTable = alwaysRewrite :: any,
    visitIndexName = alwaysRewrite :: any,
    visitIndexExpr = alwaysRewrite :: any,
    visitGroup = alwaysRewrite :: any,
    visitInterpolatedString = alwaysRewrite :: any,
    visitTypeAssertion = alwaysRewrite :: any,
    visitIfExpression = alwaysRewrite :: any,

    visitTypeReference = alwaysRewrite :: any,
    visitTypeBoolean = alwaysRewrite :: any,
    visitTypeString = alwaysRewrite :: any,
    visitTypeTypeof = alwaysRewrite :: any,
    visitTypeGroup = alwaysRewrite :: any,
    visitTypeUnion = alwaysRewrite :: any,
    visitTypeIntersection = alwaysRewrite :: any,
    visitTypeArray = alwaysRewrite :: any,
    visitTypeTable = alwaysRewrite :: any,
    visitTypeFunction = alwaysRewrite :: any,

    visitTypePackExplicit = alwaysRewrite :: any,
    visitTypePackGeneric = alwaysRewrite :: any,
    visitTypePackVariadic = alwaysRewrite :: any,

    visitToken = alwaysRewrite :: any,
    visitNil = alwaysRewrite :: any,
    visitString = alwaysRewrite :: any,
    visitBoolean = alwaysRewrite :: any,
    visitNumber = alwaysRewrite :: any,
    visitLocal = alwaysRewrite :: any,
    visitVararg = alwaysRewrite :: any,
}

local function createRewriter()
    return table.clone(default_rewriter)
end

local function exhaustiveMatch(value: never): never
	error(`Unknown value in exhaustive match: {value}`)
end

local visitExpression
local visitStatement
local visitType
local visitTypePack

local function visitToken<T>(token: libluau.Token<T>, rewriter: Rewriter): libluau.Token<T>
    return rewriter.visitToken(token :: any) :: any
end

local function replace(object: any, key: string | number, rewriter: Rewriter, func: (...any) -> (...any))
    object[key] = func(object[key], rewriter)
end

local function visitPunctuated<T, Separator>(list: libluau.Punctuated<T, Separator>, rewriter: Rewriter, visitNode: (T, Rewriter) -> (...any))
    for key, item in list do
        replace(item, "node", rewriter, visitNode)
        replace(item, "separator", rewriter, visitToken)
    end
end

local function visitLocal(node: libluau.AstLocal, rewriter: Rewriter): libluau.AstLocal
    node = rewriter.visitLocal(node)

    replace(node, "name", rewriter, visitToken)
    if node.colon then
        replace(node, "colon", rewriter, visitToken)
    end
    if node.annotation then
        replace(node, "annotation", rewriter, visitType)
    end

    return node
end

local function rewriteBlock(block: libluau.AstStatBlock, rewriter: Rewriter)
    local new_statements = table.create(#block.statements)
    for key, statement in block.statements do
        local new = visitStatement(statement, rewriter)
        new_statements[key] = new
    end

    block.statements = new_statements
end
local function visitBlock(block: libluau.AstStatBlock, rewriter: Rewriter): libluau.AstStatBlock
    local block = rewriter.visitBlock(block)

    rewriteBlock(block, rewriter)

    return block
end

local function visitIf(node: libluau.AstStatIf, rewriter: Rewriter)
    replace(node, "ifKeyword", rewriter, visitToken)
    replace(node, "condition", rewriter, visitExpression)
    replace(node, "thenKeyword", rewriter, visitToken)
    replace(node, "consequent", rewriter, visitBlock)
    for _, elseif_node in node.elseifs do
        replace(elseif_node, "elseifKeyword", rewriter, visitToken)
        replace(elseif_node, "condition", rewriter, visitExpression)
        replace(elseif_node, "thenKeyword", rewriter, visitToken)
        replace(elseif_node, "consequent", rewriter, visitBlock)
    end
    if node.elseKeyword then
        replace(node, "elseKeyword", rewriter, visitToken)
    end
    if node.antecedent then
        replace(node, "antecedent", rewriter, visitBlock)
    end
    replace(node, "endKeyword", rewriter, visitToken)
end

local function visitWhile(node: libluau.AstStatWhile, rewriter: Rewriter)
    replace(node, "whileKeyword", rewriter, visitToken)
    replace(node, "condition", rewriter, visitExpression)
    replace(node, "doKeyword", rewriter, visitToken)
    replace(node, "body", rewriter, visitBlock)
    replace(node, "endKeyword", rewriter, visitToken)
end

local function visitRepeat(node: libluau.AstStatRepeat, rewriter: Rewriter)
    replace(node, "repeatKeyword", rewriter, visitToken)
    replace(node, "body", rewriter, visitBlock)
    replace(node, "untilKeyword", rewriter, visitToken)
    replace(node, "condition", rewriter, visitExpression)
end

local function visitReturn(node: libluau.AstStatReturn, rewriter: Rewriter)
    replace(node, "returnKeyword", rewriter, visitToken)
    visitPunctuated(node.expressions, rewriter, visitExpression)
end

local function visitLocalStatement(node: libluau.AstStatLocal, rewriter: Rewriter)
    replace(node, "localKeyword", rewriter, visitToken)
    visitPunctuated(node.variables, rewriter, visitLocal)
    if node.equals then
        replace(node, "equals", rewriter, visitToken)
    end
    visitPunctuated(node.values, rewriter, visitExpression)
end

local function visitFor(node: libluau.AstStatFor, rewriter: Rewriter)
    replace(node, "forKeyword", rewriter, visitToken)
    replace(node, "variable", rewriter, visitLocal)
    replace(node, "equals", rewriter, visitToken)
    replace(node, "from", rewriter, visitExpression)
    replace(node, "toComma", rewriter, visitToken)
    replace(node, "to", rewriter, visitExpression)
    if node.stepComma then
        replace(node, "stepComma", rewriter, visitToken)
    end
    if node.step then
        replace(node, "step", rewriter, visitExpression)
    end
    replace(node, "doKeyword", rewriter, visitToken)
    replace(node, "body", rewriter, visitBlock)
    replace(node, "endKeyword", rewriter, visitToken)
end


local function visitForIn(node: libluau.AstStatForIn, rewriter: Rewriter)
    replace(node, "forKeyword", rewriter, visitToken)
    visitPunctuated(node.variables, rewriter, visitLocal)
    replace(node, "inKeyword", rewriter, visitToken)
    visitPunctuated(node.values, rewriter, visitExpression)
    replace(node, "doKeyword", rewriter, visitToken)
    replace(node, "body", rewriter, visitBlock)
    replace(node, "endKeyword", rewriter, visitToken)
end

local function visitAssign(node: libluau.AstStatAssign, rewriter: Rewriter)
    visitPunctuated(node.variables, rewriter, visitExpression)
    replace(node, "equals", rewriter, visitToken)
    visitPunctuated(node.values, rewriter, visitExpression)
end

local function visitCompoundAssign(node: libluau.AstStatCompoundAssign, rewriter: Rewriter)
    replace(node, "variable", rewriter, visitExpression)
    replace(node, "operand", rewriter, visitToken)
    replace(node, "value", rewriter, visitExpression)
end

local function visitGeneric(node: libluau.AstGenericType, rewriter: Rewriter)
    replace(node, "name", rewriter, visitToken)
    if node.equals then
        replace(node, "equals", rewriter, visitToken)
    end
    if node.default then
        replace(node, "default", rewriter, visitType)
    end

    return node
end

local function visitGenericPack(node: libluau.AstGenericTypePack, rewriter: Rewriter)
    replace(node, "name", rewriter, visitToken)
    replace(node, "ellipsis", rewriter, visitToken)
    if node.equals then
        replace(node, "equals", rewriter, visitToken)
    end
    if node.default then
        replace(node, "default", rewriter, visitTypePack)
    end

    return node
end

local function visitTypeAlias(node: libluau.AstStatTypeAlias, rewriter: Rewriter)
    if node.export then
        replace(node, "export", rewriter, visitToken)
    end
    replace(node, "typeToken", rewriter, visitToken)
    replace(node, "name", rewriter, visitToken)
    if node.openGenerics then
        replace(node, "openGenerics", rewriter, visitToken)
    end
    if node.generics then
        visitPunctuated(node.generics, rewriter, visitGeneric)
    end
    if node.genericPacks then
        visitPunctuated(node.genericPacks, rewriter, visitGenericPack)
    end
    if node.closeGenerics then
        replace(node, "closeGenerics", rewriter, visitToken)
    end
    replace(node, "equals", rewriter, visitToken)
    replace(node, "type", rewriter, visitType)
end

-- NOTE: for types that inherit Token, we create a temp copy in case the visitToken implementation
-- doesn't account for the additional members
-- (i.e instead of modifying the old it returns an entirely new or otherwise unrelated token that might not have the new types fields)

type ExtendedToken = libluau.AstStatBreak
    | libluau.AstStatContinue
    | libluau.AstExprConstantNil
    | libluau.AstExprConstantBool
    | libluau.AstExprConstantNumber
    | libluau.AstExprConstantString
    | libluau.AstExprVarargs
    | libluau.AstAttribute
    | libluau.AstTypeSingletonBool
    | libluau.AstTypeSingletonString

local function visitExtendedToken(node: ExtendedToken, rewriter: Rewriter)
    local temp = table.clone(node)
    temp = visitToken(temp, rewriter)
    for k,v in temp do (node :: any)[k] = v end
end

local function visitLocalReference(node: libluau.AstExprLocal, rewriter: Rewriter)
    replace(node, "token", rewriter, visitToken)
    replace(node, "local", rewriter, visitLocal)
end

local function visitGlobal(node: libluau.AstExprGlobal, rewriter: Rewriter)
    replace(node, "name", rewriter, visitToken)
end

local function visitCall(node: libluau.AstExprCall, rewriter: Rewriter)
    replace(node, "func", rewriter, visitExpression)
    if node.openParens then
        replace(node, "openParens", rewriter, visitToken)
    end
    visitPunctuated(node.arguments, rewriter, visitExpression)
    if node.closeParens then
        replace(node, "closeParens", rewriter, visitToken)
    end
end

local function visitUnary(node: libluau.AstExprUnary, rewriter: Rewriter)
    replace(node, "operator", rewriter, visitToken)
    replace(node, "operand", rewriter, visitExpression)
end

local function visitBinary(node: libluau.AstExprBinary, rewriter: Rewriter)
    replace(node, "lhsoperand", rewriter, visitExpression)
    replace(node, "operator", rewriter, visitToken)
    replace(node, "rhsoperand", rewriter, visitExpression)
end

local function visitFunctionBody(node: libluau.AstFunctionBody, rewriter: Rewriter): libluau.AstFunctionBody
    if node.openGenerics then
        replace(node, "openGenerics", rewriter, visitToken)
    end
    if node.generics then
        visitPunctuated(node.generics, rewriter, visitGeneric)
    end
    if node.genericPacks then
        visitPunctuated(node.genericPacks, rewriter, visitGenericPack)
    end
    if node.closeGenerics then
        replace(node, "closeGenerics", rewriter, visitToken)
    end
    replace(node, "openParens", rewriter, visitToken)
    visitPunctuated(node.parameters, rewriter, visitLocal)
    if node.vararg then
        replace(node, "vararg", rewriter, visitToken)
    end
    if node.varargColon then
        replace(node, "varargColon", rewriter, visitToken)
    end
    if node.varargAnnotation then
        replace(node, "varargAnnotation", rewriter, visitTypePack)
    end
    replace(node, "closeParens", rewriter, visitToken)
    if node.returnSpecifier then
        replace(node, "returnSpecifier", rewriter, visitToken)
    end
    if node.returnAnnotation then
        replace(node, "returnAnnotation", rewriter, visitTypePack)
    end
    replace(node, "body", rewriter, visitBlock)
    replace(node, "endKeyword", rewriter, visitToken)

    return node
end

local function visitAnonymousFunction(node: libluau.AstExprAnonymousFunction, rewriter: Rewriter)
    for key, attribute in node.attributes do
        visitExtendedToken(attribute, rewriter)
    end
    replace(node, "functionKeyword", rewriter, visitToken)
    replace(node, "body", rewriter, visitFunctionBody)
end

local function visitFunction(node: libluau.AstStatFunction, rewriter: Rewriter)
    for key, attribute in node.attributes do
        visitExtendedToken(attribute, rewriter)
    end
    replace(node, "functionKeyword", rewriter, visitToken)
    replace(node, "name", rewriter, visitExpression)
    replace(node, "body", rewriter, visitFunctionBody)
end

local function visitLocalFunction(node: libluau.AstStatLocalFunction, rewriter: Rewriter)
    for key, attribute in node.attributes do
        visitExtendedToken(attribute, rewriter)
    end
    replace(node, "localKeyword", rewriter, visitToken)
    replace(node, "functionKeyword", rewriter, visitToken)
    replace(node, "name", rewriter, visitExpression)
    replace(node, "body", rewriter, visitFunctionBody)
end

local function visitStatExpression(node: libluau.AstStatExpr, rewriter: Rewriter)
    replace(node, "expression", rewriter, visitExpression)
end

local function visitStatTypeFunction(node: libluau.AstStatTypeFunction, rewriter: Rewriter)
    if node.export then
        replace(node, "export", rewriter, visitToken)
    end
    replace(node, "type", rewriter, visitToken)
    replace(node, "functionKeyword", rewriter, visitToken)
    replace(node, "name", rewriter, visitExpression)
    replace(node, "body", rewriter, visitFunctionBody)
end

local function visitTableItem(node: libluau.AstExprTableItem, rewriter: Rewriter)
    if node.kind == "list" then
        replace(node, "value", rewriter, visitExpression)
    elseif node.kind == "record" then
        replace(node, "key", rewriter, visitToken)
        replace(node, "equals", rewriter, visitToken)
        replace(node, "value", rewriter, visitExpression)
    elseif node.kind == "general" then
        replace(node, "indexerOpen", rewriter, visitToken)
        replace(node, "key", rewriter, visitExpression)
        replace(node, "indexerClose", rewriter, visitToken)
        replace(node, "equals", rewriter, visitToken)
        replace(node, "value", rewriter, visitExpression)
    else
        exhaustiveMatch(node.kind)
    end

    if node.separator then
        replace(node, "separator", rewriter, visitToken)
    end
end

local function visitTable(node: libluau.AstExprTable, rewriter: Rewriter)
    replace(node, "openBrace", rewriter, visitToken)
    local new_entries = table.create(#node.entries)
    for key, item in node.entries do
        local new = rewriter.visitTableItem(item)
        visitTableItem(new, rewriter)
        new_entries[key] = new
    end
    node.entries = new_entries
    replace(node, "closeBrace", rewriter, visitToken)
end

local function visitIndexName(node: libluau.AstExprIndexName, rewriter: Rewriter)
    replace(node, "expression", rewriter, visitExpression)
    replace(node, "accessor", rewriter, visitToken)
    replace(node, "index", rewriter, visitToken)
end

local function visitIndexExpr(node: libluau.AstExprIndexExpr, rewriter: Rewriter)
    replace(node, "expression", rewriter, visitExpression)
    replace(node, "openBrackets", rewriter, visitToken)
    replace(node, "index", rewriter, visitExpression)
    replace(node, "closeBrackets", rewriter, visitToken)
end

local function visitGroup(node: libluau.AstExprGroup, rewriter: Rewriter)
    replace(node, "openParens", rewriter, visitToken)
    replace(node, "expression", rewriter, visitExpression)
    replace(node, "closeParens", rewriter, visitToken)
end

local function visitInterpolatedString(node: libluau.AstExprInterpString, rewriter: Rewriter)
    for i = 1, #node.strings do
        replace(node.strings, i, rewriter, visitToken)
        if i <= #node.expressions then
            replace(node.expressions, i, rewriter, visitExpression)
        end
    end
end

local function visitTypeAssertion(node: libluau.AstExprTypeAssertion, rewriter: Rewriter)
    replace(node, "operand", rewriter, visitExpression)
    replace(node, "operator", rewriter, visitToken)
    replace(node, "annotation", rewriter, visitType)
end

local function visitIfExpression(node: libluau.AstExprIfElse, rewriter: Rewriter)
    replace(node, "ifKeyword", rewriter, visitToken)
    replace(node, "condition", rewriter, visitExpression)
    replace(node, "thenKeyword", rewriter, visitToken)
    replace(node, "consequent", rewriter, visitExpression)
    for _, elseifs in node.elseifs do
        replace(elseifs, "elseifKeyword", rewriter, visitToken)
        replace(elseifs, "condition", rewriter, visitExpression)
        replace(elseifs, "thenKeyword", rewriter, visitToken)
        replace(elseifs, "consequent", rewriter, visitExpression)
    end
    replace(node, "elseKeyword", rewriter, visitToken)
    replace(node, "antecedent", rewriter, visitExpression)
end

local function visitTypeOrPack(node: libluau.AstType | libluau.AstTypePack, rewriter: Rewriter): libluau.AstType | libluau.AstTypePack
    if node.tag == "explicit" or node.tag == "generic" or node.tag == "variadic" then
        return visitTypePack(node, rewriter)
    else
        return visitType(node, rewriter)
    end
end

local function visitTypeReference(node: libluau.AstTypeReference, rewriter: Rewriter)
    if node.prefix then
        replace(node, "prefix", rewriter, visitToken)
    end
    if node.prefixPoint then
        replace(node, "prefixPoint", rewriter, visitToken)
    end
    replace(node, "name", rewriter, visitToken)
    if node.openParameters then
        replace(node, "openParameters", rewriter, visitToken)
    end
    if node.parameters then
        visitPunctuated(node.parameters, rewriter, visitTypeOrPack)
    end
    if node.closeParameters then
        replace(node, "closeParameters", rewriter, visitToken)
    end
end

local function visitTypeTypeof(node: libluau.AstTypeTypeof, rewriter: Rewriter)
    replace(node, "typeof", rewriter, visitToken)
    replace(node, "openParens", rewriter, visitToken)
    replace(node, "expression", rewriter, visitExpression)
    replace(node, "closeParens", rewriter, visitToken)
end

local function visitTypeGroup(node: libluau.AstTypeGroup, rewriter: Rewriter)
    replace(node, "openParens", rewriter, visitToken)
    replace(node, "type", rewriter, visitType)
    replace(node, "closeParens", rewriter, visitToken)
end

local function visitTypeUnion(node: libluau.AstTypeUnion, rewriter: Rewriter)
    if node.leading then
        replace(node, "leading", rewriter, visitToken)
    end
    visitPunctuated(node.types, rewriter, visitType)
end

local function visitTypeIntersection(node: libluau.AstTypeIntersection, rewriter: Rewriter)
    if node.leading then
        replace(node, "leading", rewriter, visitToken)
    end
    visitPunctuated(node.types, rewriter, visitType)
end

local function visitTypeArray(node: libluau.AstTypeArray, rewriter: Rewriter)
    replace(node, "openBrace", rewriter, visitToken)
    if node.access then
        replace(node, "access", rewriter, visitToken)
    end
    replace(node, "type", rewriter, visitType)
    replace(node, "closeBrace", rewriter, visitToken)
end

local function visitTypeTable(node: libluau.AstTypeTable, rewriter: Rewriter)
    visitToken(node.openBrace, rewriter)
    for _, entry in node.entries do
        if entry.access then
            replace(entry, "access", rewriter, visitToken)
        end
        if entry.kind == "indexer" then
            replace(entry, "indexerOpen", rewriter, visitToken)
            replace(entry, "key", rewriter, visitType)
            replace(entry, "indexerClose", rewriter, visitToken)
        elseif entry.kind == "stringproperty" then
            replace(entry, "indexerOpen", rewriter, visitToken)
            replace(entry, "key", rewriter, visitExtendedToken)
            replace(entry, "indexerClose", rewriter, visitToken)
        else
            replace(entry, "key", rewriter, visitToken)
        end
        replace(entry, "colon", rewriter, visitToken)
        replace(entry, "value", rewriter, visitType)
        if entry.separator then
            replace(entry, "separator", rewriter, visitToken)
        end
    end
    replace(node, "closeBrace", rewriter, visitToken)
end

local function visitTypeFunctionParameter(node: libluau.AstTypeFunctionParameter, rewriter: Rewriter)
    if node.name then
        replace(node, "name", rewriter, visitToken)
    end
    if node.colon then
        replace(node, "colon", rewriter, visitToken)
    end
    replace(node, "type", rewriter, visitType)

    return node
end

local function visitTypeFunction(node: libluau.AstTypeFunction, rewriter: Rewriter)
    if node.openGenerics then
        replace(node, "openGenerics", rewriter, visitToken)
    end
    if node.generics then
        visitPunctuated(node.generics, rewriter, visitGeneric)
    end
    if node.genericPacks then
        visitPunctuated(node.genericPacks, rewriter, visitGenericPack)
    end
    if node.closeGenerics then
        replace(node, "closeGenerics", rewriter, visitToken)
    end
    replace(node, "openParens", rewriter, visitToken)
    visitPunctuated(node.parameters, rewriter, visitTypeFunctionParameter)
    if node.vararg then
        replace(node, "vararg", rewriter, visitTypePack)
    end
    replace(node, "closeParens", rewriter, visitToken)
    replace(node, "returnArrow", rewriter, visitToken)
    replace(node, "returnTypes", rewriter, visitTypePack)
end

local function visitTypePackExplicit(node: libluau.AstTypePackExplicit, rewriter: Rewriter)
    if node.openParens then
        replace(node, "openParens", rewriter, visitToken)
    end
    visitPunctuated(node.types, rewriter, visitType)
    if node.tailType then
        replace(node, "tailType", rewriter, visitTypePack)
    end
    if node.closeParens then
        replace(node, "closeParens", rewriter, visitToken)
    end
end

local function visitTypePackGeneric(node: libluau.AstTypePackGeneric, rewriter: Rewriter)
    replace(node, "name", rewriter, visitToken)
    replace(node, "ellipsis", rewriter, visitToken)
end

local function visitTypePackVariadic(node: libluau.AstTypePackVariadic, rewriter: Rewriter)
    if node.ellipsis then
        replace(node, "ellipsis", rewriter, visitToken)
    end
    replace(node, "type", rewriter, visitType)
end

visitExpression = function(expression: libluau.AstExpr, rewriter: Rewriter): libluau.AstExpr
    if expression.tag == "nil" then
        expression = rewriter.visitNil(expression)
    elseif expression.tag == "boolean" then
        expression = rewriter.visitBoolean(expression)
    elseif expression.tag == "number" then
        expression = rewriter.visitNumber(expression)
    elseif expression.tag == "string" then
        expression = rewriter.visitString(expression)
    elseif expression.tag == "local" then
        expression = rewriter.visitLocalReference(expression)
    elseif expression.tag == "global" then
        expression = rewriter.visitGlobal(expression)
    elseif expression.tag == "vararg" then
        expression = rewriter.visitVararg(expression)
    elseif expression.tag == "call" then
        expression = rewriter.visitCall(expression)
    elseif expression.tag == "unary" then
        expression = rewriter.visitUnary(expression)
    elseif expression.tag == "binary" then
        expression = rewriter.visitBinary(expression)
    elseif expression.tag == "function" then
        expression = rewriter.visitAnonymousFunction(expression)
    elseif expression.tag == "table" then
        expression = rewriter.visitTable(expression)
    elseif expression.tag == "indexname" then
        expression = rewriter.visitIndexName(expression)
    elseif expression.tag == "index" then
        expression = rewriter.visitIndexExpr(expression)
    elseif expression.tag == "group" then
        expression = rewriter.visitGroup(expression)
    elseif expression.tag == "interpolatedstring" then
        expression = rewriter.visitInterpolatedString(expression)
    elseif expression.tag == "cast" then
        expression = rewriter.visitTypeAssertion(expression)
    elseif expression.tag == "conditional" then
        expression = rewriter.visitIfExpression(expression)
    else
        return exhaustiveMatch(expression.tag)
    end

    if expression.tag == "nil" then
        visitExtendedToken(expression, rewriter)
    elseif expression.tag == "boolean" then
        visitExtendedToken(expression, rewriter)
    elseif expression.tag == "number" then
        visitExtendedToken(expression, rewriter)
    elseif expression.tag == "string" then
        visitExtendedToken(expression, rewriter)
    elseif expression.tag == "local" then
        visitLocalReference(expression, rewriter)
    elseif expression.tag == "global" then
        visitGlobal(expression, rewriter)
    elseif expression.tag == "vararg" then
        visitExtendedToken(expression, rewriter)
    elseif expression.tag == "call" then
        visitCall(expression, rewriter)
    elseif expression.tag == "unary" then
        visitUnary(expression, rewriter)
    elseif expression.tag == "binary" then
        visitBinary(expression, rewriter)
    elseif expression.tag == "function" then
        visitAnonymousFunction(expression, rewriter)
    elseif expression.tag == "table" then
        visitTable(expression, rewriter)
    elseif expression.tag == "indexname" then
        visitIndexName(expression, rewriter)
    elseif expression.tag == "index" then
        visitIndexExpr(expression, rewriter)
    elseif expression.tag == "group" then
        visitGroup(expression, rewriter)
    elseif expression.tag == "interpolatedstring" then
        visitInterpolatedString(expression, rewriter)
    elseif expression.tag == "cast" then
        visitTypeAssertion(expression, rewriter)
    elseif expression.tag == "conditional" then
        visitIfExpression(expression, rewriter)
    else
        return exhaustiveMatch(expression.tag)
    end

    return expression
end

visitStatement = function(statement: libluau.AstStat, rewriter: Rewriter): libluau.AstStat
    if statement.tag == "block" then
        return visitBlock(statement, rewriter)
    elseif statement.tag == "conditional" then
        statement = rewriter.visitIf(statement)
    elseif statement.tag == "expression" then
        statement = rewriter.visitStatExpression(statement)
    elseif statement.tag == "local" then
        statement = rewriter.visitLocalDeclaration(statement)
    elseif statement.tag == "return" then
        statement = rewriter.visitReturn(statement)
    elseif statement.tag == "while" then
        statement = rewriter.visitWhile(statement)
    elseif statement.tag == "break" then
        statement = rewriter.visitBreak(statement)
    elseif statement.tag == "continue" then
        statement = rewriter.visitContinue(statement)
    elseif statement.tag == "repeat" then
        statement = rewriter.visitRepeat(statement)
    elseif statement.tag == "for" then
        statement = rewriter.visitFor(statement)
    elseif statement.tag == "forin" then
        statement = rewriter.visitForIn(statement)
    elseif statement.tag == "assign" then
        statement = rewriter.visitAssign(statement)
    elseif statement.tag == "compoundassign" then
        statement = rewriter.visitCompoundAssign(statement)
    elseif statement.tag == "function" then
        statement = rewriter.visitFunction(statement)
    elseif statement.tag == "localfunction" then
        statement = rewriter.visitLocalFunction(statement)
    elseif statement.tag == "typealias" then
        statement = rewriter.visitTypeAlias(statement)
    elseif statement.tag == "typefunction" then
        statement = rewriter.visitStatTypeFunction(statement)
    else
        return exhaustiveMatch(statement.tag)
    end

    if (statement :: any).tag == "block" then
        rewriteBlock(statement :: any, rewriter)
    elseif statement.tag == "conditional" then
        visitIf(statement, rewriter)
    elseif statement.tag == "expression" then
        visitStatExpression(statement, rewriter)
    elseif statement.tag == "local" then
        visitLocalStatement(statement, rewriter)
    elseif statement.tag == "return" then
        visitReturn(statement, rewriter)
    elseif statement.tag == "while" then
        visitWhile(statement, rewriter)
    elseif statement.tag == "break" then
        visitExtendedToken(statement, rewriter)
    elseif statement.tag == "continue" then
        visitExtendedToken(statement, rewriter)
    elseif statement.tag == "repeat" then
        visitRepeat(statement, rewriter)
    elseif statement.tag == "for" then
        visitFor(statement, rewriter)
    elseif statement.tag == "forin" then
        visitForIn(statement, rewriter)
    elseif statement.tag == "assign" then
        visitAssign(statement, rewriter)
    elseif statement.tag == "compoundassign" then
        visitCompoundAssign(statement, rewriter)
    elseif statement.tag == "function" then
        visitFunction(statement, rewriter)
    elseif statement.tag == "localfunction" then
        visitLocalFunction(statement, rewriter)
    elseif statement.tag == "typealias" then
        visitTypeAlias(statement, rewriter)
    elseif statement.tag == "typefunction" then
        visitStatTypeFunction(statement, rewriter)
    else
        return exhaustiveMatch(statement.tag)
    end

    return statement
end

visitType = function(ttype: libluau.AstType, rewriter: Rewriter): libluau.AstType
    if ttype.tag == "reference" then
        ttype = rewriter.visitTypeReference(ttype)
    elseif ttype.tag == "boolean" then
        ttype = rewriter.visitTypeBoolean(ttype)
    elseif ttype.tag == "string" then
        ttype = rewriter.visitTypeString(ttype)
    elseif ttype.tag == "typeof" then
        ttype = rewriter.visitTypeTypeof(ttype)
    elseif ttype.tag == "group" then
        ttype = rewriter.visitTypeGroup(ttype)
    elseif ttype.tag == "union" then
        ttype = rewriter.visitTypeUnion(ttype)
    elseif ttype.tag == "intersection" then
        ttype = rewriter.visitTypeIntersection(ttype)
    elseif ttype.tag == "optional" then
        -- TODO: type optional?
        -- ttype = rewriter.visitTypeOptional(ttype)
    elseif ttype.tag == "array" then
        ttype = rewriter.visitTypeArray(ttype)
    elseif ttype.tag == "table" then
        ttype = rewriter.visitTypeTable(ttype)
    elseif ttype.tag == "function" then
        ttype = rewriter.visitTypeFunction(ttype)
    else
        return exhaustiveMatch(ttype.tag)
    end

    if ttype.tag == "reference" then
        visitTypeReference(ttype, rewriter)
    elseif ttype.tag == "boolean" then
        visitExtendedToken(ttype, rewriter)
    elseif ttype.tag == "string" then
        visitExtendedToken(ttype, rewriter)
    elseif ttype.tag == "typeof" then
        visitTypeTypeof(ttype, rewriter)
    elseif ttype.tag == "group" then
        visitTypeGroup(ttype, rewriter)
    elseif ttype.tag == "union" then
        visitTypeUnion(ttype, rewriter)
    elseif ttype.tag == "intersection" then
        visitTypeIntersection(ttype, rewriter)
    elseif ttype.tag == "optional" then
        -- TODO: type optional?
        -- visitTypeOptional(type, rewriter)
    elseif ttype.tag == "array" then
        visitTypeArray(ttype, rewriter)
    elseif ttype.tag == "table" then
        visitTypeTable(ttype, rewriter)
    elseif ttype.tag == "function" then
        visitTypeFunction(ttype, rewriter)
    else
        return exhaustiveMatch(ttype.tag)
    end

    return ttype
end

visitTypePack = function(ttype: libluau.AstTypePack, rewriter: Rewriter): libluau.AstTypePack
    if ttype.tag == "explicit" then
        ttype = rewriter.visitTypePackExplicit(ttype)
    elseif ttype.tag == "generic" then
        ttype = rewriter.visitTypePackGeneric(ttype)
    elseif ttype.tag == "variadic" then
        ttype = rewriter.visitTypePackVariadic(ttype)
    else
        return exhaustiveMatch(ttype.tag)
    end

    if ttype.tag == "explicit" then
        visitTypePackExplicit(ttype, rewriter)
    elseif ttype.tag == "generic" then
        visitTypePackGeneric(ttype, rewriter)
    elseif ttype.tag == "variadic" then
        visitTypePackVariadic(ttype, rewriter)
    else
        return exhaustiveMatch(ttype.tag)
    end

    return ttype
end

return {
    createRewriter = createRewriter,
    visitBlock = visitBlock
}
