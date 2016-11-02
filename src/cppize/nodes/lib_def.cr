module Cppize
  class Transpiler
    def transpile(node : LibDef, should_return : Bool = false)
      Lines.new @failsafe do |l|
        l.block "namespace #{node.name}" do
          begin
            l.line transpile node.body
          rescue ex : Error
            l.line("#error #{ex}")
          end
        end
      end.to_s
    end

    def transpile(node : String)
      node
    end
  end
end
