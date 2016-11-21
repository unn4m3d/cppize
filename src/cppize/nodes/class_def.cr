module Cppize
  class Transpiler
    register_node ClassDef do
      unit_id = tr_uid "#{@current_namespace}::#{@current_class}::#{transpile node.name}"
      @unit_types[unit_id] = :class
      typenames = node.type_vars || [] of String

      ancestor = (node.superclass ? transpile node.superclass : "#{STDLIB_NAMESPACE}Object")
      ancestor = "public #{ancestor}"
      includes = node.search_of_type(Include).map{|x| "public virtual #{transpile x}"}

      if node.name.names.size == 1
        if @in_class
          warning "Forward declaration of class #{unit_id} is inside another class. This may cause severe issues",node,nil,@current_filename
          @classes[tr_uid "#{@current_namespace}::#{@current_class}"].line "class #{translate_name node.name.names.first}"
        else
          @forward_decl_classes.line "class #{translate_name node.name.names.first}"
        end
      else
        warning "Declaring a class with path containing more than 1 name. Ask developer to rewrite it using nested classes and modules",node,nil,@current_filename
        target_id = tr_uid "#{@current_namespace}::#{@current_class}::#{node.name.names[1..-1].join("::")}"
        target_type = search_unit_type target_id
        case target_type
        when :namespace
          @forward_decl_classes.block "namespace #{node.name.names[1..-1].join("::")}" do
            @forward_decl_classes.line "class #{translate_name node.name.names.last}"
          end
        when :class || :class_module
          if @classes.has_key? target_id
            if typenames.empty?
              @classes[target_id].line "class #{translate_name node.name.names.last}"
            else
              @classes[target_id].line "template< #{typenames.map{|x| "typename #{x}"}.join(", ")} > class #{get_name node.name}"
            end
          else
            warning "Cannot forward-declare class #{node.name.names.join("::")} as its parent class is not defined yet"
          end
        else
          warning "Cannot infer kind of parent unit of class #{node.name.names.join("::")}, skipping forward declaration",node,nil,@current_filename
        end
      end

      unit_id.gsub(/<([a-zA-Z0-9_,]+)>/) do |m|
        typenames += m.split(",")
        ""
      end

      inherits = ([ancestor]+includes).join(", ")

      @classes[unit_id] ||= ClassData.new unit_id
      if @classes[unit_id].header.empty?
        if typenames.empty?
          @classes[unit_id].header = "class #{unit_id} : #{inherits}"
        else
          @classes[unit_id].header = "template< #{typenames.map{|x| "typename #{x}"}.join(", ")} > class #{unit_id} : #{inherits}"
        end
      end

      @unit_stack << {id: unit_id, type: :class}
      old_in_class,@in_class = @in_class, true
      old_class, @current_class = @current_class, [@current_class,unit_id].join("::").gsub(/^::/,"")
      @classes[unit_id].line transpile node.body
      @in_class = old_in_class
      @current_class = old_class
      @unit_stack.pop
      ""
    end
  end
end
