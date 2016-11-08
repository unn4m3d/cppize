module Cppize
  class Transpiler
    register_node PointerOf do
      "Crystal::pointerof(#{transpile node.exp})"
    end
  end
end
