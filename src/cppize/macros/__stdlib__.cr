module Cppize
  class Transpiler
    add_macro(:__stdlib__) do |_self,call|
      raise Error.new("__stdlib__ must be called with block",call,nil,_self.current_filename) if call.block.nil?
      _self.transpile ModuleDef.new(Path.new([STDLIB_NAMESPACE.sub(/::$/,"")]),call.block.not_nil!.body)
    end
  end
end
