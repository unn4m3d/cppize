module Cppize
  class Transpiler
    register_node MultiAssign do
      names = node.values.map{|x| unique_name}
      Lines.new do |l|
        names.each_with_index do |e,i|
          l.line "auto #{e} = #{transpile node.values[i]}"
          @scopes << Scope.new unless @scopes.size > 0
          @scopes.last[e] = {symbol_type: :object, value: Var.new(e) }
        end
        names.each_with_index do |e,i|
          l.line transpile Assign.new(node.targets[i], Var.new(e) )
        end
      end.to_s
    end
  end
end
