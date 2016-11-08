module Cppize
  class Transpiler
    register_node NumberLiteral do
      (should_return? ? "return " : "") + "#{node.value.gsub("_", "'")}_cr#{node.kind}"
    end
  end
end
