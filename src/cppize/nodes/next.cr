module Cppize
  class Transpiler
    register_node Next do
      if node.exp
        raise Error.new("Nexts with expressions are not supported")
      else
        "continue"
      end
    end
  end
end
