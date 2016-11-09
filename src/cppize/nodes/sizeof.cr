module Cppize
  class Transpiler
    register_node SizeOf|InstanceSizeOf do
      (should_return? ? "return " : "") + "sizeof(#{node.exp})"
    end
  end
end
