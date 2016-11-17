enum TestEnum
  One
  Two
  Three
end

__comment__ "LOL"

# -*inline*-
module MyNamespace
  def lol(*c) : String
    c.to_s
  end

  module MyOtherNamespace
    def lol2(c : Char) : String
      c.to_s
    end
  end
end

module TemplateModule(T)
  def to_t(o) : T
    T.new(o)
  end
end

module TemplateModule2
  include TemplateModule(Int32)
end

def cool?(&block)
  if 1 && 3

  elsif 2 || 4

  else

  end
  return block.call
end

def cppize!
  printf("This code is already cppized!!!")
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
  _proc : Int32 -> Int64

  proc = ->(x : Int32){Int64.new(x)}
  if "Hello"
    printf "%s\n", s
  else
    printf "world\n"
  end

  #r = (0..10)

  cool? do
    "yes"
  end

  cool?{"y"}

  unless s
    printf "h#{cool?{ "Yes" }}\n"
  end

  while 0
    printf "0\n"
    break
  end

  until 0
    printf "1\n"
    next
  end

  case spp
  when "lol"
    foo("baz")
  when "kek"
    bar("baz")
  else
    baz("biz")
  end

  return 0
end
