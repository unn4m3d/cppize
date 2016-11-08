module Cppize
  class Transpiler
    protected def escape_cpp_string(str : String)
      str.gsub(/(?<!\\)(['"]|\\n|\n)/m) { |m| m == "\n" ? "\\n" : "\\#{m}" }
    end

    register_node StringLiteral do
      (should_return? ? "return " : "") + "\"#{escape_cpp_string node.value}\"_crstr"
    end
  end
end
