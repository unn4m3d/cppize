module Cppize
  class Transpiler
    @library_path : Array(String)
    @library_path = (if options.has_key?("no-stdlib")
      [File.join(File.dirname(Process.executable_path || ""),"stdlib/build")]
    else
      [""]
    end) + (ENV["CRYSTAL_STDLIB_PATH"]? || "").split(":")

    @required = Array(String).new

    def add_library_path(p)
      @library_path << p
    end

    def search_file(str)
      @library_path.map do |path|
        Dir.glob(File.join(path,str))
      end.select{|x| !x.empty?}.last?
    end

    register_node Require do
      path = node.string
      path += ".cr" if File.extname(path).empty?
      _f = [] of String
      if path.match(/^\.{1,2}\//)
        _f = Dir.glob(File.expand_path(path,File.dirname(@current_filename)))
      else
        _f = search_file path
        if _f.nil?
          raise Error.new("Cannot find #{path}!",node,nil,@current_filename)
        end
      end

      filename = _f.not_nil!

      old_filename = @current_filename
      str = Lines.new do |l|
        begin
          if filename.empty?
            raise Error.new("Cannot find #{path}")
          else
            filename.each do |f|
              unless @required.includes? File.expand_path f
                @required << File.expand_path f
                l.line("// BEGIN #{f} (#{path})")
                @current_filename = f
                l.line(transpile(Parser.parse(File.read(f))))
                l.line("// END #{f}")
              end
            end
          end
        rescue ex
          raise Error.new(ex.message || "Error opening #{path}",node,nil,@current_filename)
        end
      end.to_s
      @current_filename = old_filename
      str
    end
  end
end
