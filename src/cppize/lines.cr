module Cppize
  class Lines
    property? failsafe : Bool

    def initialize(@failsafe = true, &block : Lines -> _)
      @ident = 0
      @code = ""
      block.call self if block
    end

    def initialize(@failsafe = true)
      @ident = 0
      @code = ""
    end

    def line(str : String, do_not_place_semicolon : Bool = false)
      lines = str.to_s.split("\n")
      old_ident = lines.first.match(/^[\s\t]+/) || [""]
      lines.each do |l|
        @code += "\t"*@ident + l.sub(old_ident[0], "")
        @code += ";" if !do_not_place_semicolon && lines.size == 1
        @code += "\n"
      end
    end

    def line(s : Nil)
    end

    def block(header : String? = nil, &block)
      line header, true if header
      line "{", true
      @ident += 1
      begin
        block.call
      rescue ex : Transpiler::Error
        unless ex.catched?
          line "#error #{ex.message}", true
          ex.catched = true
        end
        raise ex unless @failsafe
      ensure
        @ident -= 1
        line "}", true
      end
    end

    def to_s
      @code
    end
  end
end
