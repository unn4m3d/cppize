# cppize

![Build status](https://travis-ci.org/unn4m3d/cppize.svg?branch=master)

Crystal-to-C++ transpiler [WIP]

Generated code can be compiled with c++14 compiler (tested with g++ 6.2.0)

List of supported AST nodes can be found [here](NODES.md)

## Usage

1. Compile `src/cppize/transpiler.cr` (it may take some time as it `require`s Crystal parser)
2. Launch compiled executable with `-h` flag to view all command line flags

**These features are currently not doing anything as they are just adding #define's to the beginning of source code**


Supported features (`-f...`) :
* `-fno-rtti` - disables RTTI
* `-fno-exceptions` - disables exceptions (*Currently not implemented*)
* `-fno-stdlib` - disables stdlib
* `-fno-std-string` - tells to use own implementation of string instead of `std::string` (*Currently not implemented*)
* `-fprimitive-types` - tells to use primitive types such as `int` instead of stdlib object-oriented implementations

## Things to improve in already supported AST nodes

3. Improve automatic return
4. Improve module type detection (namespace / includable)



## Development

#### Implementing nodes

See [src/cppize/nodes/expressions.cr](src/cppize/nodes/expressions.cr) for example

**Use register_node macro with caution! See [this issue](https://github.com/crystal-lang/crystal/issues/3523)**

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
