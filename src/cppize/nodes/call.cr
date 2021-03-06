require "../macros/*"

module Cppize
  class Transpiler
    @@macros = Hash(String, Proc(Transpiler, Call, String)).new

    def self.add_macro(name, &block : Transpiler, Call -> String)
      @@macros[name.to_s] = block
    end

    CPP_OPERATORS = %w(+ - * / % >> << >= <= > < == != & && | || ^ ~)

    ADDITIONAL_OPERATORS = {
      "==="   => "equals",
      "=~"    => "find",
      "<=>"   => "diff",
      "**"    => "pow",
      "class" => "get_type",
      "new"   => "__new"
    }

    register_node Call do
      if should_return?
        "return #{transpile node};"
      else
        args = node.args.map { |x| transpile x }.join(", ")

        b_arg = node.block_arg
        if b_arg.responds_to?(:name)
          args += ", #{b_arg.name}"
        end
        if node.block
          args += "#{node.args.empty? ? "" : ","} #{transpile node.block.not_nil!}"
        end

        if node.obj
          if CPP_OPERATORS.includes? node.name
            if node.args.empty?
              "(#{node.name} #{transpile node.obj})"
            else
              "(#{transpile node.obj} #{node.name} #{transpile node.args.first})"
            end
          elsif node.name == "[]"
            "#{transpile node.obj}[#{transpile node.args.first}]"
          elsif node.name == "[]="
            "#{transpile node.obj}[#{transpile node.args.first}] = #{transpile node.args[1]}"
          else

            name = ADDITIONAL_OPERATORS.has_key?(node.name) ? ADDITIONAL_OPERATORS[node.name] : translate_name node.name
            if node.obj.is_a? Self
              "this->#{name}(#{args})"
            elsif node.obj.is_a? Path
              if search_unit_type(node.obj.as(Path)) == :class_module && options.has_key? "implicit-static"
                "(#{transpile node.obj}::__static_#{translate_name name}(#{args}))"
              else
                "(#{transpile node.obj}::#{translate_name name}(#{args}))"
              end
            else
              "(#{transpile node.obj}->#{translate_name name}(#{args}))"
            end
          end
        else
          if @@macros.has_key? node.name
            @@macros[node.name].call self, node
          else
            "#{translate_name node.name}(#{args})"
          end
        end
      end
    end
  end
end
