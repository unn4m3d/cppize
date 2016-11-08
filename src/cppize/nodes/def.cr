require "../lines"

module Cppize
  class Transpiler
    @template_defs = [] of String

    protected def transpile(node : Def, should_return : Bool = false)
      try_tr node do
        Lines.new(@failsafe) do |l|
          _r = node.return_type ? transpile node.return_type : transpile_type "Auto"

          _name = translate_name node.name
          unless node.return_type
            l.line "#warning #{pretty_signature node} has not any explicit return type, using auto", true
          end

          l.line "// Generated from #{pretty_signature node}", true

<<<<<<< HEAD
        @scopes << Scope.new if @scopes.size < 1
        @scopes.first[node.name] = {symbol_type: :method, value: node}
        node.args.each do |arg|
          @scopes.first[arg.name] = {symbol_type: :object, value: arg}
        end
=======
          @scopes << Scope.new if @scopes.size < 1
          @scopes.first[node.name] = {symbol_type: :method, value: node}
          node.args.each do |arg|
            @scopes.first[arg.name] = {symbol_type: :object, value: arg}
          end
          unless node.args.all? &.restriction
            _args = node.args.select { |x| !x.restriction }.map(&.name).join(", ")
            raise Error.new("Method #{pretty_signature node} needs types of following args to be specified : #{_args}")
          end
>>>>>>> 323aaa0fbe25b04ec4c8ddb03c3ae20b7715f243

          args = node.args.map { |arg| "#{transpile arg.restriction} #{arg.name} #{arg.default_value ? transpile arg.default_value : ""}" }.join(",")
          modifiers = (node.receiver && node.receiver.to_s == "self" ? "static " : "")

          signature = "#{modifiers}#{_r} #{_name}(#{args})"

          if @in_class
            if @current_visibility != node.visibility
              l.line(transpile(node.visibility) + ":", true)
              @current_visibility = node.visibility
            end
            l.line signature

<<<<<<< HEAD
          global_s = "#{_name}"
          global_s = @current_class + "::" + global_s unless @current_class.empty?
          global_s = @current_namespace + "::" + global_s unless @current_namespace.empty?
=======
            global_s = "#{_name}(#{args})"
            global_s = @current_class + "::" + global_s unless @current_class.empty?
            global_s = @current_namespace + "::" + global_s unless @current_namespace.empty?
>>>>>>> 323aaa0fbe25b04ec4c8ddb03c3ae20b7715f243

            global_s = "#{modifiers}#{_r} #{global_s}"
            typenames = [] of String

            global_s.gsub(/\<.+\>/) do |m|
              typenames += m.sub(/^\</, "").sub(/\>$/, "").split(",").map &.strip
            end

<<<<<<< HEAD
          unless node.args.all? &.restriction
            typenames += node.args
              .select { |x| !x.restriction }
              .map{ |x| "T_#{x.name}"}
          end

          @template_defs << global_s if !@template_defs.includes? global_s && typenames.size > 0
          global_s = "template<#{typenames.map { |x| "typename #{x}" }.join(", ")}> #{global_s}" if typenames.size > 0 || @template_defs.includes? global_s
          global_s += "(#{args})"
=======
            global_s = "template<#{typenames.map { |x| "typename #{x}" }.join(", ")}> #{global_s}" if typenames.size > 0
>>>>>>> 323aaa0fbe25b04ec4c8ddb03c3ae20b7715f243

            @defs.block(global_s) do
              @defs.line transpile node.body, _r != "void"
            end
          else
            @forward_decl_defs.block("namespace #{@current_namespace}") do
              @forward_decl_defs.line signature
            end

            l.block signature do
              @scopes.unshift Scope.new
              l.line transpile node.body, _r != "void"
              @scopes.shift
            end
          end
        end.to_s
      end
    end
  end
end
