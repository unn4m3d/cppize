require "./cppize/*"
require "./ast_search"
require "compiler/crystal/**"

class Crystal::Program
  @crystal_path : CrystalPath?
end

class ArgumentError
  def initialize(message : String? = nil, cause : Exception? = nil)
    super message, cause
  end
end

module Cppize
  include Crystal

  class Transpiler
    property options

    macro register_node(klass,&block)
      protected def transpile(node : {{klass}}, *tr_options)
        should_return? = if tr_options.size == 1 && tr_options[0]?.is_a?(Bool) # To keep and old behaviour
          tr_options[0]?
        else
          tr_options.includes?(:should_return)
        end
        try_tr(node) do
          {{block.body}}
        end
      end
    end

    @forward_decl_classes = Lines.new
    @forward_decl_defs = Lines.new
    @global_vars = Lines.new
    @lib_defs = Lines.new
    @classes = Lines.new
    @defs = Lines.new
    @unions = Hash(String, String).new
    @globals_list = [] of String

    @options = Hash(String, String?).new

    alias Scope = Hash(String, NamedTuple(symbol_type: Symbol, value: ASTNode?))

    @scopes = Array(Scope).new

    @current_namespace = ""
    @in_class = false
    @current_class = ""
    @current_visibility : Visibility? = nil
    @current_filename = "<unknown>"

    def find_var(name : String) : NamedTuple(symbol_type: Symbol, value: ASTNode?)
      if name == "self"
        return {symbol_type: :pointer, value: nil}
      end
      @scopes.each do |h|
        if h.has_key? name
          return h[name]
        end
      end
      {symbol_type: :undefined, value: nil}
    end

    property? failsafe : Bool
    property? use_preprocessor_defs : Bool
    @use_preprocessor_defs = false

    def initialize(@failsafe = false)
    end

    CORE_TYPES = [
      "Int", "Int8", "Int16", "Int32", "Int64",
      "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
      "Char", "String", "Array", "StaticArray", "Pointer",
      "Size", "Object", "Hash", "Numeric", "Float",
      "Float32", "Float64", "LongFloat",
    ]

    BUILTIN_TYPES = [
      "Void", "Auto", "NativeInt",
    ]

    COMMENT = %(
/*
  Autogenerated with Cppize
  Cppize is an open-source Crystal-to-C++ transpiler
  https://github.com/unn4m3d/cppize
*/
    )

    protected def initial_defines
      lines = [] of String
      lines << "#define CPPIZE_NO_RTTI" if options.has_key? "no-rtti"
      lines << "#define CPPIZE_USE_PRIMITIVE_TYPES" if options.has_key? "primitive-types"
      lines << "#define CPPIZE_NO_EXCEPTIONS" if options.has_key? "no-exceptions"
      lines << "#define CPPIZE_NO_STD_STRING" if options.has_key? "no-std-string"
      lines << "#include <crystal/stdlib.hpp>" unless options.has_key? "no-stdlib"
      lines << "#include <cstdarg>" unless options.has_key? "no-splats"
      lines.join("\n")
    end


    def parse_and_transpile(code : String, file : String = "<unknown>")
      begin
        @current_filename = file
        code = transpile Parser.parse(code)
        # predef = Lines.new(@failsafe) do |l|
        @classes.line("// Autogenerated namespace with unions")
        @classes.block("namespace __crystal__unions") do
          @unions.each do |nu, u|
            @classes.line "class #{u} : #{nu.split("|").map { |x| "public virtual " + transpile_type x }.join(", ")} {}"
          end
        end
        @forward_decl_classes.block "namespace __crystal__unions" do
          @unions.each do |nu, u|
            @forward_decl_classes.line "class #{u}"
          end
        end
        # end.to_s

        [
          COMMENT,
          initial_defines,
          "/* :CPPIZE: Classes' forward declarations */",
          @forward_decl_classes,
          "/* :CPPIZE: Functions' forward declarations */",
          @forward_decl_defs,
          "/* :CPPIZE: Global vars */",
          @global_vars,
          "/* :CPPIZE: Bindings */",
          @lib_defs,
          "/* :CPPIZE: Classes */",
          @classes,
          "/* :CPPIZE: Functions */",
          @defs,
          code,
        ].map(&.to_s).join("\n\n")
      rescue e : Error
        @on_error.call(e)
        ""
      end
    end

    def parse_and_transpile(file : IO, name : String = "<unknown>")
      parse_and_transpile file.gets_to_end, name
    end

    def parse_and_transpile_file(file : String)
      parse_and_transpile File.read(file),file
    end

    class Error < ArgumentError
      property? catched : Bool
      property node_stack : Array(ASTNode)
      property real_filename : String

      @catched = false

      def initialize(message : String, node : ASTNode? = nil, cause : typeof(self)? = nil,@real_filename : String = "<unknown>")
        @node_stack = [] of ASTNode
        if cause.is_a?(self)
          @node_stack = cause.as(self).node_stack
        end

        unless node.nil?
          @node_stack.unshift(node.not_nil!)
        end
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
    end

    alias ErrorHandler = Error -> (Void|NoReturn)

    @on_error : ErrorHandler
    @on_warning : ErrorHandler

    @on_error = ->(e : Error){
      puts e.to_s
      exit 1
    }

    @on_warning = ->(e : Error){
      puts "/*WARNING :\n #{e.message}\n*/"
    }

    def on_warning(&o : ErrorHandler)
      @on_warning = o
    end

    def on_error(&o : ErrorHandler)
      @on_error = o
    end

    def warning(w : Error)
      @on_warning.call(w)
    end

    def warning(m : String, n : ASTNode?=nil, c : Error?=nil, f : String = @current_filename)
      warning(Error.new m,n,c,f)
    end

    protected def pretty_signature(d : Def) : String
      restrictions = d.args.map &.restriction
      "#{d.name}(#{restrictions.map(&.to_s).join(",")})" + (d.return_type ? " : #{d.return_type.to_s}" : "")
    end

    register_node ASTNode do
      if @failsafe
        "#warning Node type #{node.class} isn't supported yet"
      else
        raise Error.new("Node type #{node.class} isn't supported yet", node, nil, @current_filename)
      end
    end

    protected def transpile_type(_n : String)
      if _n.match(/\|/)
        # raise Error.new("Union types are not supported yet (type #{_n})")
        unless @unions.has_key?(_n)
          @unions[_n] = _n.gsub("::", "__").gsub("|", "_")
        end

        return "__crystal__unions::#{@unions[_n]}"
      elsif CORE_TYPES.includes?(_n)
        "Crystal::#{_n}"
      elsif BUILTIN_TYPES.includes?(_n)
        _n.downcase
      else
        _n
      end
    end

    register_node TypeNode do
      try_tr(node){(should_return? ? "return " : "") + transpile_type(node.to_s)}
    end

    register_node Path do
      #try_tr node do
        node.names[0] = transpile_type node.names.first
        (should_return? ? "return " : "") + (node.global? ? "::" : "") + "#{node.names.join("::")}"
      #end
    end

    register_node Generic do
      (should_return? ? "return " : "") + "#{transpile node.name}< #{node.type_vars.map { |x| transpile x }.join(",")} >"
    end

    register_node Nop do
      ""
    end

    protected def transpile(node : Nil, *o)
      ""
    end

    protected def translate_name(name : String)
      name.sub(/^(.*)=$/) { |m| "set_#{m}" }
          .sub(/^(.*)\?$/) { |m| "is_#{m}" }
          .sub(/^(.*)!$/) { |m| "#{m}_" }.gsub(/[!\?=]/, "")
    end

    protected def try_tr(node : ASTNode | Visibility, &block : Proc(String))
      begin
        return block.call
      rescue e : Error
        raise Error.new(e.message.to_s,nil,e,@current_filename)
      end
      return ""
    end

    protected def transpile(v : Visibility, *o)
      return try_tr v do
        case v
        when .public?
          "public"
        when .private?
          "private"
        when .protected?
          "protected"
        else
          "private"
        end
      end
    end
  end
end

require "./cppize/nodes/*"
