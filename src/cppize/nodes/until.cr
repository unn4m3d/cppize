module Cppize
  class Transpiler
    register_node Until do
      Lines.new do |l|
        l.line nil 
        l.block "while(!(#{transpile node.cond}))" do
          l.line(transpile(node.body))
        end
      end.to_s
    end
  end
end
