module Cppize
  class Transpiler
    register_node If do
      if should_return? || tr_options.includes? :ternary_if
        (should_return? ? "return " : "") +
        "((#{transpile node.cond}) ? (#{transpile node.then, :ternary_if}) : (#{transpile node.else, :ternary_if}))"
      else
        Lines.new(@failsafe) do |l|
          l.line nil
          l.block("if(#{transpile node.cond})") do
            l.line "#{transpile node.then}"
          end

          if node.else
            if node.else.is_a?(If)
              l.line "else #{transpile node.else}"
            else
              l.block("else") do
                l.line transpile node.else
              end
            end
          end
        end.to_s
      end
    end
  end
end
