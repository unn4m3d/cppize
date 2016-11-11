AST Nodes support:
==

Node          | Status        | Notes
--------------|---------------|--------------
And           | :white_check_mark: Supported |
Arg           | :heavy_exclamation_mark: Partial |
ArrayLiteral  | :heavy_exclamation_mark: Partial | :warning: Empty array literals without type restrictions are not supported<br> :warning: Needs to be implemented in stdlib
Assign        | :white_check_mark: Supported |
BinaryOp      | :white_check_mark: Supported |
Block         | :white_check_mark: Supported |
BoolLiteral   | :white_check_mark: Supported | :warning: Needs to be implemented in stdlib
Break         | :white_check_mark: Supported |
Call          | :heavy_exclamation_mark: Partial | :warning: `NamedArgument`s are not supported
Case          | :heavy_exclamation_mark: Partial | :warning: This is **NOT** expression <br> :warning: Break inside case may cause undefined behaviour
Cast          | :bangbang: Experimental | :memo: Implemented using `static_cast`. <br> :memo: `-funsafe-cast` command line option tells transpiler to use C-style casts 
CharLiteral   | :white_check_mark: Supported | :warning: Needs to be implemented in stdlib
ClassDef      | :x: Not supported |
ClassVar      | :x: Not supported |
CStructOrUnionDef | :x: Not supported |
Def           | :heavy_exclamation_mark: Partial | :warning: No class/instance defs as ClassDefs are not implemented<br>:warning: Splats are not supported
EnumDef       | :heavy_exclamation_mark: Partial | :warning: Only enums without base type are supported
Expressions   | :white_check_mark: Supported |
ExternalVar   | :heavy_exclamation_mark: Partial | :warning:
FunDef        | :white_check_mark: Supported |
Generic       | :white_check_mark: Supported |
Global        | :bangbang: Experimental |
HashLiteral   | :x: Not supported |
If            | :white_check_mark: Supported |
ImplicitObj   | :x: Not supported |
Include       | :bangbang: Experimental |
InstanceSizeOf| :white_check_mark: Supported |
IsA           | :x: Not supported |
LibDef        | :heavy_exclamation_mark: Partial |
Macro         | :x: Not supported |
MacroFor      | :x: Not supported |
MacroId       | :bangbang: Experimental |
MacroIf       | :x: Not supported |
MagicConstant | :x: Not supported |
ModuleDef     | :heavy_exclamation_mark: Partial |
MultiAssign   | :x: Not supported |
NamedArgument | :x: Not supported |
NamedTupleLiteral | :x: Not supported |
Next          | :heavy_exclamation_mark: Partial | :warning: Doesn't exits the block<br> :warning: Cannot have a value
NilableCast   | :x: Not supported |
NilLiteral    | :white_check_mark: Supported |
Nop           | :white_check_mark: Supported |
Not           | :white_check_mark: Supported |
NumberLiteral | :white_check_mark: Supported | :warning: Needs to be implemented in stdlib
Or            | :white_check_mark: Supported |
Out           | :x: Not supported |
Path          | :heavy_exclamation_mark: Partial |
PointerOf     | :white_check_mark: Supported | :warning: Needs to be implemented in stdlib
ProcLiteral   | :white_check_mark: Supported|
ProcNotation  | :white_check_mark: Supported | :warning: Needs to be implemented in stdlib
RangeLiteral  | :x: Not supported |
RegexLiteral  | :x: Not supported |
Require       | :x: Not supported |
RespondsTo    | :x: Not supported |
Return        | :heavy_exclamation_mark: Partial |
SizeOf        | :heavy_exclamation_mark: Partial | :warning: Behaves the same way as `InstanceSizeOf`
StringInterpolation | :white_check_mark: Supported |
StringLiteral | :white_check_mark: Supported | :warning: Needs to be implemented in stdlib
SymbolLiteral | :x: Not supported |
TupleLiteral  | :x: Not supported |
TypeDeclaration | :white_check_mark: Supported |
TypeNode      | :white_check_mark: Supported |
UnaryExpression | :x: Not supported |
Underscore | :x: Not supported |
UninitializedVar | :x: Not supported | :soon: Coming soon
Unless        | :white_check_mark: Supported |
Var           | :bangbang: Experimental |
VisibilityModifier | :white_check_mark: Supported |
When          | :white_check_mark: Supported
While         | :white_check_mark: Supported |
