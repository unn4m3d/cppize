module Cppize
  class Transpiler
    register_node TypeDeclaration do
      @scopes << Scope.new if @scopes.size < 1
      @scopes.first[node.var.as(Var).name] = {symbol_type: :object, value: node.var.as(Var)}
      "#{transpile node.declared_type} #{node.var.as(Var).name}"
    end
  end
end
