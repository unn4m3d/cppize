module Cppize
  class Transpiler
    register_node Case do
      Lines.new do |l|
        l.line nil
        #l.block("switch(#{transpile node.cond})") do
        node.whens.each_with_index do |wh,i|
          head = (i == 0 ? "if" : "else if")
          cond = wh.conds.reduce("") do |memo,e|
            del = (memo.to_s.empty? ? "" : " || ")
            memo.to_s + "#{del}((#{transpile node.cond}).compare(#{transpile e}))"
          end
          l.block("#{head}(#{cond})") do
            l.line transpile wh.body
          end
        end
        if node.else
          l.block "else" do
            l.line transpile node.else
          end
        end
        #end
      end.to_s
    end
  end
end
