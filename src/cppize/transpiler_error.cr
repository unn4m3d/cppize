module Cppize
  class Transpiler
    class Error < ArgumentError
      property? catched : Bool
      property node_stack : Array(ASTNode)
      property real_filename : String

      @catched = false

      def initialize(message : String, node : ASTNode? = nil, cause : self? = nil,@real_filename : String = "<unknown>")
        @node_stack = [] of ASTNode
        if cause.is_a?(self)
          @node_stack = cause.as(self).node_stack
        end

        unless node.nil?
          @node_stack.unshift(node.not_nil!)
        end
        super message, cause
      end

      def initialize(message : String, node : ASTNode? = nil, cause : Exception? = nil,@real_filename : String = "<unknown>")
        @node_stack = [] of ASTNode
        super message, cause
      end

      protected def l2s(l : Location?, file : String? = nil)
        file ||= "unknown>"
        unless l.nil?
          unless l.not_nil!.filename.nil?
            file = l.not_nil!.filename.not_nil!
          end
        end
        if l.nil?
          "at #{file} [<unknown>] "
        else
          "at #{file} [line #{l.not_nil!.line_number}; col #{l.not_nil!.column_number}]"
        end
      end

      protected def l2h(l : Location?, file : String? = nil)
        file ||= "<unknown>"
        unless l.nil?
          unless l.not_nil!.filename.nil?
            _f = l.not_nil!.filename.not_nil!
            if _f.is_a? VirtualFile
              file = _f.source
            else
              file = _f.to_s
            end
          end
        end

        if l.nil?
          {
            "file" => file,
            "line" => "unknown",
            "column"=>"unknown"
          }
        else
          {
            "file" => file,
            "line" => l.line_number,
            "column"=>l.column_number
          }
        end
      end

      def to_s(trace : Bool = false)
        str = message.to_s + "\n"
        if node_stack.size > 0
          str += "\n\t" + node_stack.map do |x|
            s = "Caused by node #{x.class.name} #{l2s x.location,@real_filename}"
            s += " (End at #{l2s x.end_location,@real_filename})"
          end.join("\n\t") + "\n"
        end

        if trace
          str += "\n\t" + backtrace.join("\n\t")
        end

        str
      end

      def to_h
        {
          message: self.message,
          backtrace: self.backtrace,
          nodes: node_stack.map do |x|
            {
              node_type: x.class.name,
              node_start: l2h(x.location, @real_filename),
              node_end: l2h(x.end_location, @real_filename),
            }
          end,
          filename: @real_filename
        }.to_h
      end

      def to_json
        to_h.to_json
      end
    end
  end
end
