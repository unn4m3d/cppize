module Cppize
  class Transpiler
    register_node Not do
      "!(#{transpile node.exp})"
    end
  end
end
