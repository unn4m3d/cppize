module Cppize
  class Transpiler
    register_node ModuleDef do
      includes = node.search_of_type(Include)
      ancestors = includes.size > 0 ? ": #{includes.map { |x| "public virtual " + transpile x.as(Include).name }.join(", ")}" : ""
      included? = false
      if options.has_key? "auto-module-type"
        included? = (@ast.not_nil!.search_of_type(Include,true).count do |x|
          x.as(Include).name.to_s.sub(/^::/,"") == (@current_namespace.empty? ? "" : @current_namespace + "::") + node.name.to_s
        end)
      end
      if !node.type_vars.nil?
        tv = node.type_vars.as(Array(String))
        @forward_decl_classes.line "template< #{tv.map { |x| "typename #{x}" }.join(", ")}> class #{node.name}"
        if includes.empty?
          @classes[get_name node.name] = ClassData.new(get_name(node.name))
        else
          @classes[get_name node.name] = ClassData.new(get_name(node.name), *(Tuple(String).from includes.map{|x| get_name(x).split(NAMES_DELIMITER)}.flatten))
        end
        @classes[get_name node.name].block "template< #{tv.map { |x| "typename #{x}" }.join(", ")}> class #{node.name} #{ancestors}" do
          @current_visibility = nil
          old_class, @current_class = @current_class, @current_class + "::" + node.name.to_s + "<#{tv.join(", ")}>"
          old_in_class, @in_class = @in_class, true
          @classes[get_name node.name].line transpile node.body
          @in_class, @current_class = old_in_class, old_class
        end
        @classes[get_name node.name].line ""
        ""
      elsif includes.size > 0 || included?
        @forward_decl_classes.line "class #{node.name}"
        @classes[get_name node.name] = ClassData.new(get_name(node.name), *(Tuple(String).from includes.map{|x| get_name(x).split(NAMES_DELIMITER)}.flatten))
        @classes[get_name node.name].block "class #{node.name} #{ancestors}" do
          @current_visibility = nil
          old_class, @current_class = @current_class, @current_class + "::" + node.name.to_s
          old_in_class, @in_class = @in_class, true
          @classes[get_name node.name].line transpile node.body
          @in_class, @current_class = old_in_class, old_class
        end
        @classes[get_name node.name].line ""
        ""
      else
        Lines.new(@failsafe) do |l|
          l.line nil
          l.block "namespace #{node.name.to_s.sub(/::$/,"")}" do
            old_namespace, @current_namespace = @current_namespace, @current_namespace + "::" + node.name.to_s
            l.line transpile node.body
            @current_namespace = old_namespace
          end
        end.to_s
      end
    end
  end
end
