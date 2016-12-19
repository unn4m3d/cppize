module Cppize
  class Transpiler
    add_macro(:__stdlib__) do |_self,call|
      if call.block.nil?
        STDLIB_NAMESPACE
      else
        _self.transpile ModuleDef.new(Path.new([STDLIB_NAMESPACE.sub(/::$/,"")]),call.block.not_nil!.body)
      end
    end
  end
end
