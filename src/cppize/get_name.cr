module Cppize
  class Transpiler
    NAMES_DELIMITER = ";"
    def get_name(node : Generic)
      transpile node.name
    end

    def get_name(node : Path)
      transpile node
    end

    def get_name(node : ASTNode)
      transpile node
    end

    def get_name(node : Nil)
      ""
    end

    def get_name(node : Union)
      node.types.map{|x| transpile x}.join(NAMES_DELIMITER)
    end
  end
end
