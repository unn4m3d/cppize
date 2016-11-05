module Cppize
  class Transpiler
    protected def transpile(node : BoolLiteral, should_return : Bool = false)
      (should_return ? "return " : "") + (node.value ? "1" : "0") + "_crbool"
    end
  end
end
