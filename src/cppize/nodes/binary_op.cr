module Cppize
  class Transpiler
    register_node And do
      (should_return? ? "return " : "")+"(#{transpile node.left} && #{transpile node.right})"
    end

    register_node Or do
      (should_return? ? "return " : "")+"(#{transpile node.left} || #{transpile node.right})"
    end
  end
end
