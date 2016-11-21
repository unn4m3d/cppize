module Cppize
  class Transpiler
    register_node Arg do
      restr = node.restriction ? transpile node.restriction : ARG_TYPE_PREFIX + node.name
      def_v = (node.default_value ? " = " + transpile node.default_value : "")
      if tr_options.includes? :splat
        unless def_v.empty?
          warning "Default values of splats are not supported",node,nil,@current_filename
        end
        "#{restr}... #{translate_name node.name}"
      elsif tr_options.includes? :tuple
        unless def_v.empty?
          warning "Default values of splats are not supported",node,nil,@current_filename
        end
        "#{STDLIB_NAMESPACE}Tuple< #{restr} > #{translate_name node.name}"
      else
        "#{restr} #{translate_name node.name}#{def_v}"
      end
    end
  end
end
