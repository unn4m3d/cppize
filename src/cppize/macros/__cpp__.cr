module Cppize
  class Transpiler
    add_macro(:__cpp__) do |_self, call|
      Lines.new do |l|
        if call.block.nil?
          call.args.each do |arg|
            if arg.responds_to? :value
              l.line arg.value.to_s, true
            end
          end
        else
          b = call.block.not_nil!
          h = call.args.first?
          if h.responds_to? :value
            l.block h.value.to_s do
              l.line _self.transpile b.body
            end
          end
        end
      end.to_s
    end
  end
end
