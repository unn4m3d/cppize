module Cppize
  class Transpiler
    register_node BoolLiteral do
      (should_return? ? "return " : "") + (node.value ? "1" : "0") + "_crbool"
    end
  end
end
