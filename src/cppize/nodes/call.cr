require "../macros/*"

module Cppize
  class Transpiler
    @@macros = Hash(String, Proc(Transpiler, Call, String)).new

    def self.add_macro(name, &block : Transpiler, Call -> String)
      @@macros[name.to_s] = block
    end

    CPP_OPERATORS = %w(+ - * / % >> << >= <= > < == != & && | || ^)

    ADDITIONAL_OPERATORS = {
      "==="   => "equals",
      "=~"    => "find",
      "<=>"   => "diff",
      "**"    => "pow",
      "class" => "get_type",
    }

    def transpile(node : Call, should_return : Bool = false)
      if should_return
        "return #{transpile node}"
      else
        if node.obj
          if CPP_OPERATORS.includes? node.name
            "(#{transpile node.obj} #{node.name} #{transpile node.args.first})"
          elsif node.name == "[]"
            "#{transpile node.obj}[#{transpile node.args.first}]"
          elsif node.name == "[]="
            "#{transpile node.obj}[#{transpile node.args.first}] = #{transpile node.args[1]}"
          else
            name = ADDITIONAL_OPERATORS.has_key?(node.name) ? ADDITIONAL_OPERATORS[node.name] : node.name
            if name.ends_with?("=")
              name = name.sub(/^(.*)=$/) { |m| "get_#{m}" }
            end

            name = name.gsub(/\?/, "_").gsub(/\!/, "__")
            if node.obj.is_a? Self
              "this->#{name}(#{node.args.map { |x| transpile x }.join(", ")})"
            else
              "(#{transpile node.obj}.#{name}(#{node.args.map { |x| transpile x }.join(", ")})"
            end
          end
        else
          if @@macros.has_key? node.name
            @@macros[node.name].call self, node
          else
            "#{node.name}(#{node.args.map { |x| transpile x }.join(",")})"
          end
        end
      end
    end
  end
end
