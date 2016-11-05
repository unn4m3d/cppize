module Cppize
  class Transpiler
    protected def transpile(node : MacroId, should_return : Bool = false)
      (should_return ? "return " : "") + node.to_s
    end
  end
end
