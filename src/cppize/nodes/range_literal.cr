module Cppize
  class Transpiler
    register_node RangeLiteral do
      (should_return? ? "return " : "") +
      "#{STDLIB_NAMESPACE}::Range< decltype(#{transpile node.from}) >(#{transpile node.from},#{transpile node.to},#{node.exclusive? ? "true" : "false"})"
    end
  end
end
