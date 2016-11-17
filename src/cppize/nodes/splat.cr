module Cppize
  class Transpiler
    register_node Splat do
      "#{STDLIB_NAMESPACE}::splat(#{transpile node.exp, :ternary_if})"
    end
  end
end
