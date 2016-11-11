module Cppize
  class Transpiler
    register_node Cast do
      (should_return? ? "return " : "") + "((#{node.to})#{node.obj})"
    end
  end
end
