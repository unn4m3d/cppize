require "../lines"

module Cppize
  class Transpiler
    @template_defs = [] of String

    ARG_TYPE_PREFIX = "_T_"

    register_node Def do
      Lines.new(@failsafe) do |l|
        typenames = [] of String

        typenames += node.args.select{|x| !x.restriction}.map{|x| ARG_TYPE_PREFIX + x.name}

        args = node.args.map do |arg|
          restr = arg.restriction ? transpile arg.restriction : ARG_TYPE_PREFIX + arg.name
          def_v = (arg.default_value ? " = " + transpile arg.default_value : "")
          "#{restr} #{arg.name}#{def_v}"
        end.join(", ")


        @scopes << Scope.new if @scopes.empty?
        node.args.each do |arg|
          @scopes.first[arg.name] = {symbol_type: :object, value: arg}
        end

        if node.block_arg
          block = node.block_arg.not_nil!
          typenames << ARG_TYPE_PREFIX + block.name + "_ret"
          typenames << "... " + ARG_TYPE_PREFIX + block.name + "_args"
          pref = ARG_TYPE_PREFIX
          b_type = "#{pref}#{block.name}_ret, #{pref}#{block.name}_args..."
          args += "#{args.empty? ? "" : ","} Crystal::Proc<#{b_type}> #{block.name}"
          @scopes.first[block.name] = {symbol_type: :object, value: block}
        end

        def_type = (node.return_type ? transpile node.return_type : "auto")

        modifiers = (node.receiver.to_s == "self" ? "static " : "")

        common_signature = "#{translate_name node.name}(#{args})"
        local_template = (typenames.size > 0 ? "template<#{typenames.map{|x| "typename #{x}"}.join(", ")} > " : "")
        local_signature = "#{local_template}#{modifiers}#{def_type} #{common_signature}"

        template_name = "#{@current_namespace}::#{@current_class}::#{node.name}"

        unless node.args.all? &.restriction
          @template_defs << template_name unless @template_defs.includes? template_name
        end

        @current_namespace.gsub(/\<.+\>/) do |m|
            typenames += m.sub(/^\</, "").sub(/\>$/, "").split(",").map &.strip
        end

        global_template = ((typenames.size > 0 || @template_defs.includes? template_name) ? "template<#{typenames.map{|x| "typename #{x}"}.join(", ")} > " : "")

        namesp = (@current_namespace.empty? ? "" : @current_namespace + "::")

        if @in_class
          Lines.new @failsafe do
            if @current_visibility != node.visibility
              l.line "public:", true
              @current_visibility = node.visibility
              l.line local_signature
            end
          end

          global_signature = "#{global_template}#{modifiers}#{def_type} #{namesp}#{@current_class}::#{common_signature}"

          @defs.block global_signature do
            if def_type == "void"
              @defs.line transpile(node.body)
            else
              @defs.line transpile(node.body,:should_return)
            end
          end

        else
          #global_signature = "#{global_template} #{modifiers} #{def_type} #{namesp}#{common_signature}"

          if namesp.empty?
            @forward_decl_defs.line local_signature
          else
            @forward_decl_defs.block "namespace #{namesp}" do
              @forward_decl_defs.line local_signature
            end
          end

          l.block local_signature do
            if def_type == "void"
              l.line transpile(node.body)
            else
              l.line transpile(node.body,:should_return)
            end
          end
        end
      end.to_s
    end
  end
end
