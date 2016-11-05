module Cppize
  class Transpiler
    protected def transpile(node : If, should_return : Bool = false)
      Lines.new(@failsafe) do |l|
        l.block "if(#{transpile node.cond})" do
          l.line(transpile(node.then, should_return))
        end
        if node.else && !node.else.is_a?(Nop)
          l.block "else" do
            l.line(transpile(node.else, should_return))
          end
        end
      end.to_s
    end
  end
end
