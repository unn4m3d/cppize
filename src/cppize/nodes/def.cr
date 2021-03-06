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
          arg_str = "#{args.empty? ? "" : ","} #{STDLIB_NAMESPACE}Proc<#{b_type}> #{block.name}"
          args += arg_str
          @scopes.first[block.name] = {symbol_type: :object, value: block}
        end

        def_type = (node.return_type ? transpile node.return_type : "auto")

        _marr = [] of String
        _marr << "static" if node.receiver.is_a?(Self)
        if options.has_key?("all-virtual") || @attribute_set.map(&.name).includes?("Virtual") || node.abstract?
          _marr << "virtual"
        end

        modifiers = _marr.join(" ")
        modifiers += " " unless _marr.empty?
        common_signature = "#{translate_name node.name}(#{args})"
        local_template = (typenames.size > 0 ? "template<#{typenames.map{|x| "typename #{x}"}.join(", ")} > " : "")
        local_signature = "#{local_template}#{modifiers}#{def_type} #{common_signature}"

        template_name = "#{full_cid}::#{node.name}"

        unless node.args.all? &.restriction
          @template_defs << template_name unless @template_defs.includes? template_name
        end

        typenames += @typenames.flatten

        global_template = ((typenames.size > 0 || @template_defs.includes? template_name) ? "template<#{typenames.map{|x| "typename #{x}"}.join(", ")} > " : "")


        if @in_class
          if @current_visibility != node.visibility
            l.line "public:", true
            @current_visibility = node.visibility
          end
          l.line local_signature

          if @unit_stack.last[:type] == :class_module && options.has_key? "implicit-static"
            l.line transpile Def.new(
              "__static_"+node.name,
              node.args,
              Call.new(
                Call.new(
                  Path.new("#{@current_class}#{@typenames.last.empty? ? "" : "<" + @typenames.last.join(", ") + " >"}"),
                  "__new"
                ),
                node.name,
                node.args.map{|x| Var.new(x.name).as(ASTNode)}
              ),
              Self.new
            )
          end

          global_signature = "#{global_template}#{modifiers}#{def_type} #{full_cid}::#{common_signature}"

          @unit_stack << {id: global_signature, type: :class_def}

          @defs.block global_signature do
            if def_type == "void"
              @defs.line transpile(node.body)
            else
              @defs.line transpile(node.body,:should_return)
            end
          end

          @unit_stack.pop

        else
          #global_signature = "#{global_template} #{modifiers} #{def_type} #{namesp}#{common_signature}"
          if @current_namespace.empty?
            @forward_decl_defs.line local_signature
          else
            @forward_decl_defs.block "namespace #{@current_namespace.join("::")}" do
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
              pass_args << "#{STDLIB_NAMESPACE}make_tuple(#{x.name}...)"
            else
              args << transpile x
              pass_args << translate_name x.name
            end
      end
      args_str = args.join(", ")

      def_type = (d.return_type ? transpile d.return_type : "auto")

      _marr = [] of String
      _marr << "static" if d.receiver.is_a?(Self)
      _marr << "virtual" if options.has_key? "all-virtual" || @attribute_set.index{|x| x.name == "Virtual" } || d.abstract?

      modifiers = _marr.join(" ")
      modifiers += " " unless _marr.empty?
      local_template = (typenames.size > 0 ? "template<#{typenames.map{|x| "typename #{x}"}.join(", ")} > " : "")

      typenames += @typenames.flatten
      template_name = "#{full_cid}::#{d.name}"

      global_template = ((typenames.size > 0 || @template_defs.includes? template_name) ? "template<#{typenames.map{|x| "typename #{x}"}.join(", ")} > " : "")

      local_signature = "#{local_template}#{modifiers}#{def_type} #{translate_name d.name}(#{args_str})"
      if @in_class
        global_signature = "#{global_template}#{modifiers}#{def_type} #{full_cid}::#{translate_name d.name}(#{args_str})"

        @defs.block global_signature do
          @defs.line "return #{d.name}(#{pass_args.join(", ")})"
        end
        return local_signature
      else
        if @current_namespace.empty?
          @forward_decl_defs.line local_signature
        else
          @forward_decl_defs.block "namespace #{@current_namespace.join("::")}" do
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
