module Cppize
  class Transpiler
    def transpile(node : TypeDeclaration, should_return : Bool = false)
      @scopes << Scope.new if @scopes.size < 1
      @scopes.first[node.var.as(Var).name] = {symbol_type: :object, value: node.var.as(Var)}
      "#{transpile node.declared_type} #{node.var.as(Var).name}"
    end
  end
end
