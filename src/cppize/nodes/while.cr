module Cppize
  class Transpiler
    register_node While do
      Lines.new do |l|
        l.line nil # To avoid https://github.com/crystal-lang/crystal/issues/3523
        l.block "while(#{transpile node.cond})" do
          l.line(transpile(node.body))
        end
      end.to_s
    end
  end
end
