enum TestEnum
  One
  Two
  Three
end

__comment__ "LOL"

# -*inline*-
module MyNamespace
  def lol(c : Char) : String
    c.to_s
  end
end

lib A_Lib
  fun a(i : Int32) : Void
  fun b = "c"(i : Float64) : Float32
end

def main : NativeInt
  s : Pointer(Char)
  spp : Pointer(Pointer(Char))
  s = "HelloWorld"
  spp = pointerof(s)
  s = "Hello World"
  s += "s"
  if "Hello"
    printf "%s\n", s
  else
    printf "world\n"
  end

  unless s
    printf "h\n"
  end

  while 0
    printf "0\n"
    break
  end

  until 0
    printf "1\n"
    next
  end

  return 0
end
