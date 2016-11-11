module Cppize
  class Transpiler
    register_node PointerOf do
      "#{STDLIB_NAMESPACE}::pointerof(#{transpile node.exp})"
    end
  end
end
