module Cppize
  class Transpiler
    register_node MacroId do
      (should_return? ? "return " : "") + node.to_s
    end
  end
end
