module Cppize
  class Transpiler
    register_node ExternalVar do
      unless node.real_name.nil?
        warning "External var cannot have different identifier than its real name",node,nil,@current_filename
      end

      "extern \"C\" #{transpile node.type_spec} #{translate_name node.name}"
    end
  end
end
