module Cppize
  class Transpiler
    register_node Return do
      "return" + (node.exp ? " #{transpile node.exp}" : "")
    end
  end
end
