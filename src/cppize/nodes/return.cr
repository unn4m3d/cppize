module Cppize
  class Transpiler
    register_node Return do
      if node.exp
        code = transpile node.exp, :should_return
        code += ";" unless code.ends_with?(";")
        code
      else
        "return;"
      end
    end
  end
end
