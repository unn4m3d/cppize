__cpp__ "#include <cstdio>"
__cpp__ "namespace crystal{\n typedef int int32; template<typename T> using pointer = T*;\n}"
__cpp__ %(constexpr const char* operator"" _crstr(const char* lit, size_t s){return lit;} )
__cpp__ "typedef int nativeint;"

enum TestEnum
  One
  Two
  Three
end

def main : NativeInt
  s : Pointer(Char)
  s = "HelloWorld"
  s = "Hello World"
  s += "s"
  printf "%s\n", s
end
