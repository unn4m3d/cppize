module Cppize
  class Transpiler
    add_macro(:__cpp__) do |_self, call|
      Lines.new do |l|
        call.args.each do |arg|
          if arg.responds_to? :value
            l.line arg.value.to_s, true
          end
        end
      end.to_s
    end
  end
end
