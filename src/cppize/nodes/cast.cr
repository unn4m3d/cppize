module Cppize
  class Transpiler
    register_node Cast do
      if options.has_key?("unsafe-cast")
        (should_return? ? "return " : "") + "((#{transpile node.to})#{transpile node.obj})"
      else
        (should_return? ? "return " : "") + "static_cast<#{transpile node.to}>(#{transpile node.obj})"
      end
    end
  end
end
