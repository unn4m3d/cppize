module Cppize
  class Transpiler
    register_node ClassVar do
      if @unit_stack.last[:type] == :class_def
      (should_return? ? "return " : "") + node.name
      else
        "static #{node.name}"
      end
    end
  end
end
