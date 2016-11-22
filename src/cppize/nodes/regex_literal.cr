module Cppize
  class Transpiler
    protected def escape_regex(r : String) : String
      escape_cpp_string r.gsub("\\","\\\\")
    end

    register_node RegexLiteral do
      (should_return? ? "return " : "") + "#{STDLIB_NAMESPACE}Regex(#{transpile node.value, :regex},\"#{node.options}\")"
    end
  end
end
