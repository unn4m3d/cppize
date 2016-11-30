module Cppize
  class Transpiler
    register_node Attribute do
      @attribute_set << node
      ""
    end
  end
end
