module Cppize
  class Transpiler
    register_node CharLiteral do
      "'#{escape_cpp_string node.value.to_s}'_crchar"
    end
  end
end
