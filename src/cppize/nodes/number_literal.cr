module Cppize
  class Transpiler
    protected def transpile(node : NumberLiteral, should_return : Bool = false)
      (should_return ? "return " : "") + "#{node.value.gsub("_", "'")}_cr#{node.kind}"
    end
  end
end
