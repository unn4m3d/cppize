module Cppize
  class Transpiler
    add_macro(:__comment__) do |_self, call|
      "/*#{call.args.reduce("") do |memo,arg|
        m = memo.to_s
        if arg.responds_to? :value
          m + arg.value.to_s + "\n"
        else
          m + arg.to_s
        end
      end}*/"
    end
  end
end
