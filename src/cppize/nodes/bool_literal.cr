module Cppize
  class Transpiler
    def transpile(node : BoolLiteral, should_return : Bool = false)
      (should_return ? "return " : "") + node.value.to_s + "_crbool"
    end
  end
end