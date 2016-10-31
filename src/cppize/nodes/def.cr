require "../lines"

module Cppize
  class Transpiler
    def transpile(node : Def, should_return : Bool = false)
      Lines.new(@failsafe) do |l|
        _r = node.return_type ? transpile node.return_type : transpile_type "Auto"

        unless node.return_type
          l.line "#warning #{pretty_signature node} has not any explicit return type, using auto", true
        end

        l.line "// Generated from #{pretty_signature node}", true

        @scopes << Scope.new if @scopes.size < 1
        @scopes.first[node.name] = {symbol_type: :method, value: node}
        unless node.args.all? &.restriction
          _args = node.args.select { |x| !x.restriction }.map(&.name).join(", ")
          raise Error.new("Method #{pretty_signature node} needs types of following args to be specified : #{_args}")
        end

        args = node.args.map { |arg| "#{transpile arg.restriction} #{arg.name} #{arg.default_value ? transpile arg.default_value : ""}" }.join(",")
        modifiers = (node.receiver && node.receiver.to_s == "self" ? "static " : "")

        l.block "#{modifiers}#{_r} #{node.name}(#{args})" do
          @scopes.unshift Scope.new
          l.line transpile node.body, _r != "void"
          @scopes.shift
        end
      end.to_s
    end
  end
end
