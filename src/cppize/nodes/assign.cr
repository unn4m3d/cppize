module Cppize
  class Transpiler
    protected def transpile(node : Assign, should_return : Bool = false)
      try_tr(node) do
        (should_return ? "return" : "") + "#{transpile node.target} = #{transpile node.value}"
      end
    end
  end
end
