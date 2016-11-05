module Cppize
  class Transpiler
    protected def transpile(node : Until, should_return : Bool = false)
      Lines.new do |l|
        l.block "while(!(#{transpile node.cond}))" do
          l.line(transpile(node.body))
        end
      end.to_s
    end
  end
end
