module Cppize
  class Transpiler
    register_node Block do
      if should_return?
        "return #{transpile node}"
      else

        args = node.args.map{|x| "auto #{x.name}"}.join(", ")

        Lines.new do |l|
          l.line nil
          l.block "[&](#{args})" do
            l.line transpile node.body
          end
        end.to_s
      end
    end
  end
end
