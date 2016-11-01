module Cppize
  class Transpiler
    def transpile(node : Next, should_return : Bool = false)
      if node.exp
        raise Error.new("Nexts with expressions are not supported")
      else
        "continue"
      end
    end
  end
end
