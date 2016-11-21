module Cppize
  class Transpiler
    register_node StringInterpolation do
      if tr_options.includes? :regex
        (should_return? ? "return " : "")+node.expressions.map{|x| "(#{transpile x, :regex}).to_s()"}.join(" + ")
      else
        (should_return? ? "return " : "")+node.expressions.map{|x| "(#{transpile x}).to_s()"}.join(" + ")
      end
    end
  end
end
