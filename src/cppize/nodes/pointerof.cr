module Cppize
  class Transpiler
    def transpile(node : PointerOf, should_return : Bool = false)
      "crystal::pointerof(#{transpile node.exp})"
    end
  end
end
