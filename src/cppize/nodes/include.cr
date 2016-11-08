module Cppize
  class Transpiler
    register_node Include do
      if @in_class
        ""
      else
      "using namespace #{transpile node.name}"
      end
    end
  end
end
