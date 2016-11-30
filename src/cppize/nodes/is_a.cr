module Cppize
  class Transpiler
    register_node IsA do
      "#{transpile node.obj}.is_a<#{transpile node.const} >()"
    end
  end
end
