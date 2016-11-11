module Cppize
  class ClassData
    property dependencies : Array(String)
    property lines : Lines
    property name : String
    property dep_source : ClassDataHash?
    @lines = Lines.new

    def initialize(@name)
      @dependencies = [] of String
    end

    def initialize(@name, *depends)
      @dependencies = depends.to_a
    end

    def depends_on?(name : String)
      return false if dep_source.nil?
      @dependencies.any?{|x| dep_source.not_nil![x].name == name || dep_source.not_nil![x].depends_on? name }
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

    delegate :line, to: lines

    def block(a=nil,&b)
      lines.block(a,&b)
    end
  end

  class ClassDataHash < Hash(String,ClassData)
    def to_s
      keys = self.keys.sort{|x,y| x <=> y}
      keys.map{|x| self[x].lines.to_s}.join("\n\n")
    end

    def []=(k,v : ClassData)
      v.dep_source = self
      super k.to_s,v
    end
  end
end
