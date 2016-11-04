module Cppize
  class Transpiler
    def transpile(node : ModuleDef, s : Bool = false)
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
