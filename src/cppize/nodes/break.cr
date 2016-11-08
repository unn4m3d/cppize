module Cppize
  class Transpiler
    register_node Break do
      if node.exp
        raise Error.new("Breaks with expressions are not supported",node,nil,@current_filename)
      else
        "break"
      end
    end
  end
end
