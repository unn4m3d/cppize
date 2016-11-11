module Cppize
  class ClassData
    property dependencies : Array(ClassData)
    property lines : Lines
    property name : String
    @lines = Lines.new
    def initialize(@name, *depends)
      @dependencies = depends.to_a
    end

    def depends_on?(name : String)
      result = false
      @dependencies.each do |d| # Uses 1 loop
        if d.name == name || d.depends_on?(name)
          result = true
          break
        end
      end
      return result
    end

    def depends_on?(c : self)
      depends_on? c.name
    end

    def <=>(other : self)
      if other.depends_on? self
        1
      elsif self.depends_on? other
        -1
      else
        0
      end
    end
  end

  class ClassDataHash < Hash(String,ClassData)
    def to_s
      keys = self.keys.sort{|x,y| x <=> y}
      keys.map{|x| self[x].lines.to_s}.join("\n\n")
    end
  end
end
