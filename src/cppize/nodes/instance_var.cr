module Cppize
  class Transpiler
    register_node InstanceVar do
      if @unit_stack.last[:type] == :class_def
        (should_return? ? "return " : "") + "this->#{translate_name node.name}"
      else
        (should_return? ? "return " : "") + translate_name node.name
      end
    end
  end
end
