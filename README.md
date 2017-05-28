# cppize

![Build status](https://travis-ci.org/unn4m3d/cppize.svg?branch=master)

Crystal-to-C++ transpiler [WIP]

Generated code can be compiled with c++14 compiler (tested with g++ 6.2.0)

List of supported AST nodes can be found [here](NODES.md)

You can try it [here](https://unn4m3d.github.io/cppize)

## CLI Usage

1. Compile `src/cppize/transpiler.cr` (it may take some time as it `require`s Crystal parser)
2. Launch compiled executable with `-h` flag to view all command line flags

#### Implemented `-fFEATURE`s
Flag  | Description
------|---------------
`-funsafe-cast` | Tells transpiler to transpile casts to C-style casts instead of `static_cast`s
`-fprimitive-types` | Tells transpiler to use fundamental C++ types when possible
`-fauto-module-type`| Allows transpiler to detect if module is included <br> :warning: This option can slow down transpilation
`-fimplicit-static` | Enables static module methods' calls

## Library Usage
```crystal
# Initialize transpiler
transpiler = Cppize::Transpiler.new

# Set error and warning callbacks
transpiler.on_warning{|e| puts e.to_s}
transpiler.on_error{|e| puts e.to_s; exit 1}

# Transpile file
transpiled_code = transpiler.parse_and_transpile_file("./file.cpp.cr")
# Transpile code from IO
transpiled_code = transpiler.parse_and_transpile_file(File.open("./file.cpp.cr"),"./file.cpp.cr")
# Transpile code from string
transpiled_code = transpiler.parse_and_transpile_file("def foo; bar(true) end","<test>")
```

## Things to improve in already supported AST nodes

3. Improve automatic return
4. Improve module type detection (namespace / includable)



## Development

#### Implementing nodes

See [src/cppize/nodes/expressions.cr](src/cppize/nodes/expressions.cr) for example

#### Adding transpile-time macros

See [src/cppize/macros/\_\_cpp\_\_.cr](src/cppize/macros/__cpp__.cr) for example

## Contributing

1. Fork it ( https://github.com/unn4m3d/cppize/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [unn4m3d](https://github.com/unn4m3d) unn4m3d - creator, maintainer
