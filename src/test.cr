__cpp__ "#include <cstdio>"
__cpp__ "namespace crystal{\n typedef int int32; \n}"
__cpp__ %(constexpr const char* operator"" _str(const char* lit, size_t s){return lit;} )
__cpp__ "typedef int nativeint;"

def main : NativeInt
  s = "HelloWorld"
  printf "%s\n", s
end
