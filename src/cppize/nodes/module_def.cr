module Cppize
  class Transpiler
    def transpile(node : ModuleDef, s : Bool = false)
      Lines.new(@failsafe) do |l|
        l.block "#{modif}namespace #{node.name}" do
          l.line transpile node.body
        end
      end.to_s
    end
  end
end
