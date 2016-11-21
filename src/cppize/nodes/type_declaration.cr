module Cppize
  class Transpiler
    register_node TypeDeclaration do
      @scopes << Scope.new if @scopes.size < 1
      case node.var
      when Var || InstanceVar || ClassVar
        v = node.var
        if v.responds_to? :name
          @scopes.first[v.name.to_s] = {symbol_type: :object, value: node.var}
          next "#{transpile node.declared_type} #{translate_name v.name.to_s}"
        end
      when Global
        @scopes.last[node.var.as(Global).name] = {symbol_type: :object, value: node.var}
        unless @globals_list.includes? node.var.as(Global).name
          @globals_list << node.var.as(Global).name
          @global_vars.block("namespace __globals") do
            @global_vars.line "#{transpile node.declared_type} #{translate_name node.var.as(Global).name}"
          end

          next ""
        end
      else
        raise Error.new("Node type #{node.var.class.name} isn't supported in type declarations yet",node.var,nil,@current_filename)
      end
      ""
    end
  end
end
