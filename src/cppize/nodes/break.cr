module Cppize
  class Transpiler
    protected def transpile(node : Break, should_return : Bool = false)
      if node.exp
        raise Error.new("Breaks with expressions are not supported",node,nil,@current_filename)
      else
        "break"
      end
    end
  end
end
