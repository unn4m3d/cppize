module Cppize
  class Transpiler

    @unit_types = Hash(String,Symbol).new

    def search_unit_type(name : String)
      return @unit_types[tr_uid name]? || :undefined
    end

    def search_unit_type(name : Path)
      if name.global?
        return @unit_types[name.names.join("::")]? || :undefined
      end

      uid = tr_uid "#{@current_namespace}::#{@current_class}::#{name.names.join("::")}"
      return @unit_types[uid]? || :undefined
    end

    register_node ModuleDef do
      unit_id = tr_uid ([full_cid] + node.name.names).join("::")
      includes = node.search_of_type(Include)
      ancestors = includes.size > 0 ? ": #{includes.map { |x| "public virtual " + transpile x.as(Include).name }.join(", ")}" : ": public virtual #{STDLIB_NAMESPACE}Module"
      included? = false
      if options.has_key? "auto-module-type"
        included? = (@includes.count do |x|
          x.as(Include).name.to_s.sub(/^::/,"") == ([full_cid] + node.name.names).join("::")
        end)
      end

      typenames = [] of String

      unless node.type_vars.nil?
        typenames += node.type_vars.not_nil!
      end

      if typenames.empty? && !included? && includes.empty? && !@in_class
        Lines.new do |l|
          l.line nil
          l.block("namespace #{node.name.names.join("::")}") do
            @unit_stack << {id: unit_id, type: :namespace}
            @unit_types[unit_id] = :namespace
            @current_namespace += node.name.names
            l.line transpile node.body
            node.name.names.size.times{@current_namespace.pop}
            @unit_stack.pop
          end
        end.to_s
      else
        ancestors = (includes.empty? ? ": public #{STDLIB_NAMESPACE}Module" : ": "+includes.map{|x| "public virtual #{transpile x.as(Include).name}"}.join(", "))
        target_id = if node.name.names.size == 1
          tr_uid full_cid
        else
          warning Warning::LONG_PATH do
            warn "Please use nested classes and modules instead of long paths",node,nil,@current_filename
          end
          [tr_uid(full_cid),node.name.names[1..-1]].flatten.join("::")
        end

        local_template = if typenames.empty?
          ""
        else
          "template< #{typenames.map{|x| "typename #{x}"}.join(", ")} > "
        end

        if @classes.has_key? target_id
          @classes[target_id].block "#{local_template} class #{node.name.names.last}#{ancestors}" do
            @current_class += node.name.names
            @unit_types[unit_id] = :class_module
            @unit_stack << {id: unit_id, type: :class_module}
            (node.name.names.size-1).times{@typenames << [] of String}
            @typenames << typenames
            oic,@in_class = @in_class,true
            @classes[target_id].line transpile node.body
            node.name.names.size.times  do
              @typenames.pop
              @current_class.pop
            end
            @unit_stack.pop
            @in_class = oic
          end
        else
          if @in_class
            raise Error.new "Cannot declare module as its parent is not defined",node,nil,@current_filename
          else
            if @classes.has_key? unit_id
              warning Warning::REDECLARATION do
                warn "#{unit_id} is already defined", node,nil, @current_filename
              end
            else
              @classes[unit_id] ||= ClassData.new unit_id
            end
            if @classes[unit_id].header.empty?
              @classes[unit_id].header = "#{local_template} class #{node.name.names.last}#{ancestors}"
              @current_class += node.name.names
              (node.name.names.size-1).times{@typenames << [] of String}
              @typenames << typenames
              oic,@in_class = @in_class,true
              @unit_types[unit_id] = :class_module
              @unit_stack << {id: unit_id, type: :class_module}
              @classes[unit_id].line transpile node.body
              @in_class = oic
              @unit_stack.pop
              node.name.names.size.times  do
                @typenames.pop
                @current_class.pop
              end

            else
              warning Warning::REDECLARATION do
                warn "Class #{unit_id} is already declared, skipping declaration",node,nil,@current_filename
              end
            end
          end
        end
        ""
      end
    end
  end
end
