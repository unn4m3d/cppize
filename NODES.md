AST Nodes support:
==

Node          | Status        | Notes
--------------|---------------|--------------
And           | :white_check_mark: Supported |
Arg           | :heavy_exclamation_mark: Partial |
Alias         | :heavy_exclamation_mark: Partial | :warning: Specialized aliases are not supported yet
ArrayLiteral  | :heavy_exclamation_mark: Partial | :warning: Empty array literals without type restrictions are not supported<br> :warning: Needs to be implemented in stdlib
Assign        | :white_check_mark: Supported |
Attribute     | :white_check_mark: Supported | :warning: Only one attribute is implemented
BinaryOp      | :white_check_mark: Supported |
Block         | :white_check_mark: Supported |
BoolLiteral   | :white_check_mark: Supported | :warning: Needs to be implemented in stdlib
Break         | :white_check_mark: Supported |
Call          | :heavy_exclamation_mark: Partial | :warning: `NamedArgument`s are not supported
Case          | :heavy_exclamation_mark: Partial | :warning: This is **NOT** expression <br> :warning: Cannot compare types yet
Cast          | :bangbang: Experimental | :memo: Implemented using `static_cast`. <br> :memo: `-funsafe-cast` command line option tells transpiler to use C-style casts
CharLiteral   | :white_check_mark: Supported | :warning: Needs to be implemented in stdlib
ClassDef      | :heavy_exclamation_mark: Partial | :warning: Variadic templates are not supported<br> :warning: Named Type Vars are not supported
ClassVar      | :white_check_mark: Supported |
CStructOrUnionDef | :x: Not supported |
Def           | :heavy_exclamation_mark: Partial | :warning: Splats are partially supported; see Splat for details
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
InstanceVar   | :white_check_mark: Supported |
IsA           | :bangbang: Experimental |
LibDef        | :heavy_exclamation_mark: Partial |
Macro         | :x: Not supported |
MacroFor      | :x: Not supported |
MacroIf       | :x: Not supported |
MagicConstant | :x: Not supported |
ModuleDef     | :heavy_exclamation_mark: Partial |
MultiAssign   | :white_check_mark: Supported |
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
RangeLiteral  | :white_check_mark: Supported | :warning: Needs to be implemented in stdlib
RegexLiteral  | :bangbang: Experimental |
Require       | :heavy_exclamation_mark: Partial |
RespondsTo    | :x: Not supported |
Return        | :heavy_exclamation_mark: Partial |
Self          | :white_check_mark: Supported |
SizeOf        | :heavy_exclamation_mark: Partial | :warning: Behaves the same way as `InstanceSizeOf`
Splat         | :heavy_exclamation_mark: Partial | :warning: There is no support for calls with variable number of arguments yet<br> :warning: See Splats section below
StringInterpolation | :white_check_mark: Supported |
StringLiteral | :heavy_exclamation_mark: Partial | :warning: Needs to be implemented in stdlib<br> :warning: Escape sequences are not supported
SymbolLiteral | :x: Not supported |
TupleLiteral  | :x: Not supported |
TypeDeclaration | :white_check_mark: Supported |
TypeNode      | :white_check_mark: Supported |
Underscore | :x: Not supported |
UninitializedVar | :x: Not supported |
Union         | :bangbang: Experimental | :warning: Needs to be implemented in stdlib
Unless        | :white_check_mark: Supported |
Var           | :bangbang: Experimental |
VisibilityModifier | :white_check_mark: Supported |
When          | :white_check_mark: Supported |
While         | :white_check_mark: Supported |


Splats
--

Splats are supported partially. For example:

```crystal
def a(b,*c,d)
  #...
end

#OK
a foo, bar, baz, biz

#OK
a foo, *bar

#WRONG
a *baz

#WRONG
a *baz,foo

```
