module Cppize
  class Transpiler
    register_node ClassDef do
      raw_uid = ([full_cid] + node.name.names).join("::")
      unit_id = tr_uid raw_uid
      @unit_types[unit_id] = :class
      typenames = [] of String

      unless node.type_vars.nil?
        typenames += node.type_vars.not_nil!
      end

      ancestor = (node.superclass ? transpile node.superclass : "#{STDLIB_NAMESPACE}Object")
      ancestor = "public #{ancestor}"
      includes = node.search_of_type(Include).map{|x| "public virtual #{transpile x.as(Include).name}" }

      if node.name.names.size == 1
        if @in_class
          warning Warning::NESTED do
            warn "Forward declaration of class #{unit_id} is inside another class. This may cause severe issues",node,nil,@current_filename
          end
          @classes[tr_uid "#{(@current_namespace+@current_class).join("::")}"].line "class #{translate_name node.name.names.first}"
        else
          @forward_decl_classes.line "class #{translate_name node.name.names.first}"
        end
      else
        warning Warning::LONG_PATH do
          warn "Declaring a class with path containing more than 1 name. Ask developer to rewrite it using nested classes and modules",node,nil,@current_filename
        end
        target_id = tr_uid (@current_namespace+@current_class+node.name.names[1..-1]).join("::")
        target_type = search_unit_type target_id
        case target_type
        when :namespace
          if node.name.global?
            @forward_decl_classes.block "namespace #{node.name.names[1..-1].join("::")}" do
              @forward_decl_classes.line "class #{translate_name node.name.names.last}"
            end
          else
            @forward_decl_classes.block "namespace #{target_id}" do
              @forward_decl_classes.line "class #{translate_name node.name.names.last}"
            end
          end
        when :class || :class_module
          if @classes.has_key? target_id
            if typenames.empty?
              @classes[target_id].line "class #{translate_name node.name.names.last}"
            else
              @classes[target_id].line "template< #{typenames.map{|x| "typename #{x}"}.join(", ")} > class #{get_name node.name}"
            end
          else
            warning Warning::FD_SKIP do
              warn "Cannot forward-declare class #{node.name.names.join("::")} as its parent class is not defined yet"
            end
          end
        else
          warning Warning::FD_SKIP|Warning::KIND_INF do
            warn "Cannot infer kind of parent unit of class #{node.name.names.join("::")}, skipping forward declaration",node,nil,@current_filename
          end
        end
      end

      typenames += @typenames.flatten


      inherits = ([ancestor]+includes).join(", ")

      @classes[unit_id] ||= ClassData.new unit_id
      if @classes[unit_id].header.strip.empty?
        if typenames.empty?
          @classes[unit_id].header = "class #{unit_id} : #{inherits}"
        else
          @classes[unit_id].header = "template< #{typenames.map{|x| "typename #{x}"}.join(", ")} > class #{raw_uid} : #{inherits}"
        end
      else
        warning Warning::REDECLARATION do
          warn "Class #{get_name node.name} is already declared"
        end
      end

      @unit_stack << {id: unit_id, type: :class}
      old_in_class,@in_class = @in_class, true
      @current_class += node.name.names
      (node.name.names.size-1).times{@typenames << [] of String}
      @typenames << typenames
      @classes[unit_id].line transpile node.body
      @in_class = old_in_class
      node.name.names.size.times do
        @current_class.pop
        @typenames.pop
      end
      @attribute_set.each do |attr|
        if attr.name == "Header"
          next if attr.named_args.nil?
          attr.named_args.not_nil!.each do |arg|
            case arg.name
            when "local"
              @classes[unit_id].c_deps << %("#{arg.value.as(StringLiteral).value}")
            when "system" || "global"
              @classes[unit_id].c_deps << "<#{arg.value.as(StringLiteral).value}>"
            else
              raise Error.new("Wrong type of header : #{arg.name}",node,nil,@current_filename)
            end
          end
        end
      end
      @unit_stack.pop
      ""
    end
  end
end
