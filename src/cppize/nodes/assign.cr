module Cppize
  class Transpiler
    def transpile(node : Assign, should_return : Bool = false)
      (should_return ? "return" : "") + "#{transpile node.target} = #{transpile node.value}"
    end
  end
end
