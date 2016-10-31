module Cppize
  class Transpiler
    def transpile(node : TypeDeclaration, should_return : Bool = false)
      "#{transpile_type node.declared_type.to_s} #{node.var.as(Var).name};"
    end
  end
end
