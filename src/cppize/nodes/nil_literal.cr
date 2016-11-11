module Cppize
  class Transpiler
    register_node NilLiteral do
      (should_return? ? "return " : "") + "#{STDLIB_NAMESPACE}::NIL"
    end
  end
end
