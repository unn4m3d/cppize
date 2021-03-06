module Cppize
  class Transpiler

    register_node Expressions do
      Lines.new do |l|
        if should_return?
          node.expressions[0..-2].each do |e|
            l.line transpile e
          end

          expr = node.expressions.last
          ret = ""
          case expr
          when Return || Nop || TypeDeclaration || If || While || TypeNode
          else
            ret = "return "
          end
          l.line ret + transpile(expr)
        else
          node.expressions.each do |e|
            l.line transpile e
          end
        end
      end.to_s
    end
  end
end
