module Cppize
  class Transpiler
    register_node Alias do
      "template<typename ... _Alias_T_#{node.name}> using #{node.name} = #{transpile node.value}<_Alias_T_#{node.name}...>"
    end
  end
end
