module Cppize
  class Transpiler
    register_node Case do
      Lines.new do |l|
        l.line nil
        l.block("switch(#{transpile node.cond})") do
          node.whens.each do |wh|
            wh.conds.each do |cond|
              l.line "case #{transpile cond}:",true
            end
            l.line transpile(wh.body)
            l.line "break"
          end

          if node.else
            l.line "default:",true
            l.line transpile node.else
            l.line "break"
          end
        end
      end.to_s
    end
  end
end
