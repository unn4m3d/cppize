require "../macros/*"

module Cppize
  class Transpiler
    @@macros = Hash(String, Proc(Transpiler, Call, String)).new

    def self.add_macro(name, &block : Transpiler, Call -> String)
      @@macros[name.to_s] = block
    end

    def transpile(node : Call, should_return : Bool = false)
      if node.obj
        raise Error.new("Object calls are currently not supported")
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
