module Cppize
  class Transpiler
    register_node Global do
      unless @globals_list.includes? node.name
        raise Error.new("Global variable $#{node.name} is not declared yet",node,nil,@current_filename)
      end
      "__globals::#{translate_name node.name}"
    end
  end
end
