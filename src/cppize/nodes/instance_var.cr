module Cppize
  class Transpiler
    register_node InstanceVar do
      if @unit_stack.last[:type] == :class_def
        (should_return? ? "return " : "") + "this->#{node.name}"
      else
        (should_return? ? "return " : "") + node.name
      end
    end
  end
end
