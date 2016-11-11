module Cppize
  class Transpiler
    register_node ArrayLiteral do
      if node.elements.empty? && !node.of && !options[:allow_empty_arrays]?
        raise Error.new("You must specify array type of empty array literals",node,nil,@current_filename)
      end

      arr_type = (node.of ? transpile node.of : "decltype(#{transpile node.elements.first})")

      (should_return? ? "return " : "") + "#{STDLIB_NAMESPACE}::Array< #{arr_type} >{ #{node.elements.map{|x| transpile x}.join(", ")} }"
    end
  end
end
