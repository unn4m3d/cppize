module Cppize
  class Transpiler
    protected def transpile(node : LibDef, should_return : Bool = false)
      @lib_defs.block "namespace #{node.name}" do
        begin
          @lib_defs.line transpile node.body
        rescue ex : Error
          @lib_defs.line("#error #{ex}")
        end
      end
      ""
    end

    def transpile(node : String)
      node
    end
  end
end
