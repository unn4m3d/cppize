module Cppize
  class Transpiler
    def escape_cpp_string(str : String)
      str.gsub(/(?<!\\)(['"]|\\n|\n)/m) { |m| m == "\n" ? "\\n" : "\\#{m}" }
    end

    def transpile(node : StringLiteral, should_return : Bool = false)
      (should_return ? "return " : "") + "\"#{escape_cpp_string node.value}\"_crstr"
    end
  end
end
