module Cppize
  class Transpiler
    register_node StringInterpolation do
      (should_return? ? "return " : "")+node.expressions.map{|x| "(#{transpile x}).to_s()"}.join(" + ")
    end
  end
end
