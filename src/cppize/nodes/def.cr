require "../lines"

module Cppize
  class Transpiler
    @template_defs = [] of String

    ARG_TYPE_PREFIX = "_T_"

    register_node Def do
      Lines.new(@failsafe) do |l|
        typenames = [] of String

        typenames += node.args.select{|x| !x.restriction}.map{|x| ARG_TYPE_PREFIX + x.name}
        _args = [] of String
        node.args.each_with_index do |arg,i|
          if node.splat_index && node.splat_index.not_nil! == i
            _args << transpile(arg,:tuple)
          else
            _args << transpile arg
          end
        end
        args = _args.join(", ")

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
          arg_str = "#{args.empty? ? "" : ","} #{STDLIB_NAMESPACE}::Proc<#{b_type}> #{block.name}"
          args += arg_str
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

        @current_class.gsub(/\<.+\>/) do |m|
            typenames += m.sub(/^\</, "").sub(/\>$/, "").split(",").map &.strip
        end

        global_template = ((typenames.size > 0 || @template_defs.includes? template_name) ? "template<#{typenames.map{|x| "typename #{x}"}.join(", ")} > " : "")

        namesp = (@current_namespace.empty? ? "" : @current_namespace + "::")

        if @in_class
          if @current_visibility != node.visibility
            l.line "public:", true
            @current_visibility = node.visibility
          end
          l.line local_signature

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

        l.line add_def_with_splat node
      end.to_s
    end

    protected def add_def_with_splat(d : Def)
      return nil if d.splat_index.nil?
      typenames = [] of String

      typenames += d.args.select{|x| !x.restriction}.map{|x| ARG_TYPE_PREFIX + x.name}

      idx = d.splat_index.not_nil!

      args = [] of String
      pass_args = [] of String

      d.args.each_with_index do |x,i|
            if idx == i
              args << transpile(x, :splat)
              pass_args << "#{STDLIB_NAMESPACE}::make_tuple(#{x.name}...)"
            else
              args << transpile x
              pass_args << translate_name x.name
            end
      end
      args_str = args.join(", ")

      namesp = (@current_namespace.empty? ? "" : @current_namespace + "::")
      def_type = (d.return_type ? transpile d.return_type : "auto")

      modifiers = (d.receiver.to_s == "self" ? "static " : "")
      local_template = (typenames.size > 0 ? "template<#{typenames.map{|x| "typename #{x}"}.join(", ")} > " : "")

      @current_namespace.gsub(/\<.+\>/) do |m|
          typenames += m.sub(/^\</, "").sub(/\>$/, "").split(",").map &.strip
      end

      @current_class.gsub(/\<.+\>/) do |m|
          typenames += m.sub(/^\</, "").sub(/\>$/, "").split(",").map &.strip
      end
      template_name = "#{@current_namespace}::#{@current_class}::#{d.name}"

      global_template = ((typenames.size > 0 || @template_defs.includes? template_name) ? "template<#{typenames.map{|x| "typename #{x}"}.join(", ")} > " : "")

      local_signature = "#{local_template}#{modifiers}#{def_type} #{translate_name d.name}(#{args_str})"
      if @in_class
        global_signature = "#{global_template}#{modifiers}#{def_type} #{namesp}#{@current_class}::#{translate_name d.name}(#{args_str})"

        @defs.block global_signature do
          @defs.line "return #{d.name}(#{pass_args.join(", ")})"
        end
        return local_signature
      else
        if namesp.empty?
          @forward_decl_defs.line local_signature
        else
          @forward_decl_defs.block "namespace #{namesp}" do
            @forward_decl_defs.line local_signature
          end
        end

        Lines.new @failsafe do |l|
          l.block(local_signature) do
            l.line "return #{d.name}(#{pass_args.join(", ")})"
          end
        end.to_s
      end
    end
  end
end
