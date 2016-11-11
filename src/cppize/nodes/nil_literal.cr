module Cppize
  class Transpiler
    register_node NilLiteral do
      (should_return? ? "return " : "") + "Crystal::NIL"
    end
  end
end
