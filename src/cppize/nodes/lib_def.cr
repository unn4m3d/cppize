module Cppize
  class Transpiler
    register_node LibDef do
      @lib_defs.block "namespace #{node.name}" do
        @lib_defs.line transpile node.body
      end
      ""
    end

    #register_node String do # TODO : remove this
    #  node
    #end
  end
end
