# Implemented macros

### \_\_comment\_\_

This macro places its arguments into `/* multiline comment */`

### \_\_cpp\_\_

If called with block, this macro uses first argument or empty string as block header and places transpiled body into a block.


For example,
```crystal
__cpp__ "int main()" do
  __cpp__ "return 0"
end
```
results in

```cpp
int main()
{
  return 0;
}
```

If there is no block given, this macro places each argument into output file

```crystal
__cpp__ "foo()"
__cpp__ "bar()","baz()"
```

Results in

```cpp
foo();
bar();
baz();
```

:warning: **WARNING** This macro won't emit anything unless called with literal arguments

### \_\_cppize\_version\_\_

This macro call turns into string literal containing cppize version string

### define

Defines given symbols

### undef

Undefines given symbols
