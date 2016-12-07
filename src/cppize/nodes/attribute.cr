module Cppize
  class Transpiler
    register_node Attribute, :keep_attributes do
      @attribute_set << node
      ""
    end
  end
end
