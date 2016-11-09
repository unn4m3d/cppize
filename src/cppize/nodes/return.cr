module Cppize
  class Transpiler
    register_node Return do
      if node.exp
        transpile node.exp, :should_return
      else
        "return"
      end
    end
  end
end
