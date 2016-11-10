module Cppize
  class Transpiler
    register_node ProcLiteral do
      @scopes << Scope.new if @scopes.empty?
      args = node.def.args.map do |arg|
        restr = (arg.restriction ? transpile arg.restriction : "auto")
        def_v = (arg.default_value ? " = #{transpile arg.default_value}" : "")
        @scopes.first[arg.name] = {symbol_type: :object, value: arg}
        "#{restr} #{arg.name}#{def_v}"
      end.join(", ")

      Lines.new do |l|
        l.line nil
        l.block("[&](#{args})") do
          l.line transpile(node.def.body,:should_return)
        end
      end.to_s
    end
  end
end
