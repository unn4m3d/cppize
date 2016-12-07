module Cppize
  class Transpiler
    register_node NilableCast do
      (should_return? ? "return " : "") + "#{STDLIB_NAMESPACE}nilable_cast<#{transpile node.to}>(#{transpile node.obj})"  
    end
  end
end
