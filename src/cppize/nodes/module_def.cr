module Cppize
  class Transpiler

    @unit_types = Hash(String,Symbol).new

    def search_unit_type(name : String)
      return @unit_types[name]? || :undefined
    end

    def search_unit_type(name : Path)
      if name.global?
        return @unit_types[name.names.join("::")]? || :undefined
      end

      uid = "#{@current_namespace}::#{@current_class}::#{name.names.join("::")}".gsub(/^::/,"")
      return @unit_types[uid]? || :undefined
    end

    register_node ModuleDef do
      unit_id = "#{@current_namespace}::#{@current_class}::#{node.name.names.join("::")}".gsub(/^::/,"")
      includes = node.search_of_type(Include)
      ancestors = includes.size > 0 ? ": #{includes.map { |x| "public virtual " + transpile x.as(Include).name }.join(", ")}" : ""
      included? = false
      if options.has_key? "auto-module-type"
        included? = (@ast.not_nil!.search_of_type(Include,true).count do |x|
          x.as(Include).name.to_s.sub(/^::/,"") == (@current_namespace.empty? ? "" : @current_namespace + "::") + node.name.to_s
        end)
      end
      if !node.type_vars.nil?
        @unit_types[unit_id] = :class_module
        @unit_stack.push({id: unit_id, type: :class_module})
        tv = node.type_vars.as(Array(String))
        #@forward_decl_classes.line "template< #{tv.map { |x| "typename #{x}" }.join(", ")}> class #{node.name}"

        unless @classes[get_name node.name]
          if includes.empty?
            @classes[get_name node.name] = ClassData.new(get_name(node.name))
          else
            @classes[get_name node.name] = ClassData.new(get_name(node.name), *(Tuple(String).from includes.map{|x| get_name(x).split(NAMES_DELIMITER)}.flatten))
          end
          @classes[get_name node.name].header= "template< #{tv.map { |x| "typename #{x}" }.join(", ")}> class #{node.name} #{ancestors}"
        end
        @current_visibility = nil
        old_class, @current_class = @current_class, @current_class + "::" + node.name.to_s + "<#{tv.join(", ")}>"
        old_in_class, @in_class = @in_class, true
        @classes[get_name node.name].line transpile node.body
        @in_class, @current_class = old_in_class, old_class
        @unit_stack.pop
        ""
      elsif includes.size > 0 || included?
        @unit_types[unit_id] = :class_module
        @unit_stack.push({id: unit_id, type: :class_module})
        unless @classes[get_name node.name]
          @classes[get_name node.name] = ClassData.new(get_name(node.name), *(Tuple(String).from includes.map{|x| get_name(x).split(NAMES_DELIMITER)}.flatten))
          @classes[get_name node.name].header= "class #{node.name} #{ancestors}"
        end
        @current_visibility = nil
        old_class, @current_class = @current_class, @current_class + "::" + node.name.to_s
        old_in_class, @in_class = @in_class, true
        @classes[get_name node.name].line transpile node.body
        @in_class, @current_class = old_in_class, old_class
        @unit_stack.pop
        ""
      else
        @unit_types[unit_id] = :namespace
        @unit_stack.push({id: unit_id, type: :namespace})
        Lines.new(@failsafe) do |l|
          l.line nil
          l.block "namespace #{node.name.to_s.sub(/::$/,"")}" do
            old_namespace, @current_namespace = @current_namespace, @current_namespace + "::" + node.name.to_s
            l.line transpile node.body
            @current_namespace = old_namespace
          end
          @unit_stack.pop
        end.to_s
      end
    end
  end
end
