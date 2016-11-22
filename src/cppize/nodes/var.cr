module Cppize
  class Transpiler
    register_node Var do
      found = find_var node.name
      result = (@unit_stack.last[:type] != :class_def && node.name.match(/[^A-Za-z]+[A-Z]/) ? "const " : "")
      case found[:symbol_type]
      when :undefined
        result = "auto "
        @scopes.push Scope.new if @scopes.size < 1
        @scopes.first[node.name] = {symbol_type: :variable, value: node}
      when :object || :pointer || :primitive
      else
        # raise Error.new("Cannot use non-variable as variable")
      end
      result += node.name
      result
    end
  end
end
