module Cppize
  class Transpiler
    register_node Assign do
        (should_return? ? "return" : "") + "#{transpile node.target} = #{transpile node.value}"
    end
  end
end
