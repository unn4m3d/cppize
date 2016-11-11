module Cppize
  class Transpiler
    register_node ProcNotation do
      if node.inputs.not_nil!.any? &.is_a?(Underscore)
        raise Error.new("Underscore isn't supported yet",node,nil,@current_filename)
      end
      args = node.inputs.not_nil!.map{|x| transpile x}.join(", ")
      "#{STDLIB_NAMESPACE}::Proc< #{node.output ? transpile node.output : "void"}" + (node.inputs.not_nil!.empty? ? "" : ", "+args) + " >"
    end
  end
end
