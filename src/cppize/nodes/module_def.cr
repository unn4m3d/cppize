module Cppize
  class Transpiler
    protected def transpile(node : ModuleDef, s : Bool = false)
      includes = node.search_of_type(Include)
      ancestors = includes.size > 0 ? ": #{includes.map { |x| "public virtual " + transpile x.as(Include).name }.join(", ")}" : ""

      if !node.type_vars.nil?
        tv = node.type_vars.as(Array(String))
        @forward_decl_classes.line "template< #{tv.map { |x| "typename #{x}" }.join(", ")}> class #{node.name}"

        @classes.block "template< #{tv.map { |x| "typename #{x}" }.join(", ")}> class #{node.name} #{ancestors}" do
          @current_visibility = nil
          old_class, @current_class = @current_class, @current_class + "::" + node.name.to_s + "<#{tv.join(", ")}>"
          old_in_class, @in_class = @in_class, true
          @classes.line transpile node.body
          @in_class, @current_class = old_in_class, old_class
        end
        @classes.line ""
        ""
      elsif includes.size > 0
        @forward_decl_classes.line "class #{node.name}"

        @classes.block "class #{node.name} #{ancestors}" do
          @current_visibility = nil
          old_class, @current_class = @current_class, @current_class + "::" + node.name.to_s
          old_in_class, @in_class = @in_class, true
          @classes.line transpile node.body
          @in_class, @current_class = old_in_class, old_class
        end
        @classes.line ""
        ""
      else
        Lines.new(@failsafe) do |l|
          l.block "namespace #{node.name}" do
            old_namespace, @current_namespace = @current_namespace, @current_namespace + "::" + node.name.to_s
            l.line transpile node.body
            @current_namespace = old_namespace
          end
        end.to_s
      end
    end
  end
end
