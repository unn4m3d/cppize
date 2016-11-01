module Cppize
  class Transpiler
    add_macro(:__comment__) do |_self, call|
      s = "/*\n"
      call.args.each { |x| s += x.to_s.gsub(/(?<!\\)"/, "") + "\n" }
      s + "*/"
    end
  end
end
