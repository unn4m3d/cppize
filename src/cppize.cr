require "./cppize/*"
require "./ast_search"
require "compiler/crystal/**"

# W/ Love; From Neo.
#................00000000000
#..............00,,,,,,,0,,,,,,00 
#.............0,,,,,,,,,0,,,,,,,,,0 
#............0,,,,,,,,,,0,,,,,,,,,,0 
#...........0,,,,,,,,,,,0,,,,,,,,,,,0 
#...........0,,,,,,,,,,,,,,,,,,,,,,,,0 
#...........0,,,,,,,,,,,,,,,,,,,,,,,,0 
#...........0,,,,,,,,,,,,,,,,,,,,,,,,0 
#............0,,,,,,,,,,,,,,,,,,,,,0 
#.............000000000000000 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.............0,,,,,,,,,,,,,,,,,,,0 
#.........000,,,,,,,,,,,,,,,,,,,,,,000 
#.......00,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,00 
#......0,,,,,,,,,,,,,,,,,0,,,,,,,,,,,,,,,,0 
#.....0,,,,,,,,,,,,,,,,,,,0,,,,,,,,,,,,,,,,0 
#....0,,,,,,,,,,,,,,,,,,,,,0,,,,,,,,,,,,,,,,0 
#...0,,,,,,,,,,,,,,,,,,,,,,0,,,,,,,,,,,,,,,,0 
#...0,,,,,,,,,,,,,,,,,,,,,,0,,,,,,,,,,,,,,,,0 
#...0,,,,,,,,,,,,,,,,,,,,,0,,,,,,,,,,,,,,,,0 
#....0,,,,,,,,,,,,,,,,,,,0,,,,,,,,,,,,,,,,0 
#.....0,,,,,,,,,,,,,,,,,0,,,,,,,,,,,,,,,0


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

  @[Flags]
  enum Warning : UInt64
    REDECLARATION
    FD_SKIP
    KIND_INF
    NAME_MISMATCH
    LONG_PATH
    NESTED
    ARGUMENT_MISMATCH
  end

  def self.warning_list
    Warning.names.map(&.downcase.gsub("_","-"))
  end

  def self.warning_from_string(str)
    i = warning_list.index str
    if i.nil?
      return 0
    else
      return 2u64**i
    end

  end

  class Transpiler
    property options

    STDLIB_NAMESPACE = "Crystal::"

    @@features = Hash(String,Proc(String,Void)).new

    def self.features_list
      @@features.keys
    end

    @attribute_set = [] of Attribute

    property enabled_warnings

    @enabled_warnings : UInt64

    @enabled_warnings = 0u64

    macro register_node(klass,*opts,&block)
      def transpile(node : {{klass}}, *tr_options)
        should_return? = if tr_options.size == 1 && tr_options[0]?.is_a?(Bool) # To keep and old behaviour
          tr_options[0]?
        else
          tr_options.includes?(:should_return)
        end
        %code = try_tr(node) do
          {{block.body}}
        end

        {% unless opts.includes? :keep_attributes %}
          @attribute_set = [] of Attribute
        {% end %}
        %code
      end
    end

    def tr_uid(s)
      s.gsub(/^::/,"").gsub(/::::/,"::").gsub(/<.*>/,"")
    end

    def register_feature(feature : String, &on_enable : Proc(String,Void))
      @@features[feature] = on_enable
    end

    @forward_decl_classes = Lines.new
    @forward_decl_defs = Lines.new
    @global_vars = Lines.new
    @lib_defs = Lines.new
    @classes = ClassDataHash.new
    @defs = Lines.new
    @globals_list = [] of String

    @options = Hash(String, String?).new

    alias UnitInfo = NamedTuple(id: String, type: Symbol)
    alias Scope = Hash(String, NamedTuple(symbol_type: Symbol, value: ASTNode?))

    @scopes = Array(Scope).new
    @typenames = [] of Array(String)
    @unit_stack = [ {id: "::", type: :top_level} ] of UnitInfo
    @current_namespace = [] of String
    @in_class = false
    @current_class = [] of String
    @current_visibility : Visibility? = nil

    protected def current_cid
      if @current_class.empty?
        ""
      else
        @current_class.zip(@typenames).map{|x| "#{x.first}< #{x.last.join(", ")} >"}.join("::")
      end
    end

    protected def full_cid
      (@current_namespace+[current_cid]).join("::")
    end

    getter current_filename

    @current_filename = "<unknown>"
    @ast : ASTNode?

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

    def post_initialize!
      @@features.each do |k,v|
        if @options.has_key? k
          v.call k
        end
      end
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
      lines << "using #{STDLIB_NAMESPACE.sub(/::$/,"")};" unless options.has_key? "no-stdlib" || options.has_key? "no-using-stdlib" || STDLIB_NAMESPACE.empty?
      lines.join("\n")
    end

    @includes = Array(Include?).new

    def parse_and_transpile(code : String, file : String = "<unknown>")
      begin
        @current_filename = file
        @ast = Parser.parse(code)
        unless @ast.nil?
          @includes = @ast.not_nil!.search_of_type(Include,true).map{|x| x.as(Include?)}
        end
        code = transpile @ast
        # predef = Lines.new(@failsafe) do |l|
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

    def warn(w : Error)
      @on_warning.call(w)
    end

    def warn(m : String, n : ASTNode?=nil, c : Error?=nil, f : String = @current_filename)
      warn(Error.new m,n,c,f)
    end

    def warning(w,&b)
      if (@enabled_warnings.to_u64 & w.to_u64) != 0
        b.call
      end
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
      if CORE_TYPES.includes?(_n)
        "#{STDLIB_NAMESPACE}#{_n}"
      elsif BUILTIN_TYPES.includes?(_n)
        _n.downcase
      else
        _n
      end
    end

    register_node Union do
      "#{STDLIB_NAMESPACE}Union< #{node.types.map{|x| transpile x}.join(", ")} >"
    end

    register_node TypeNode do
      (should_return? ? "return " : "") + transpile_type(node.to_s)
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
      if CPP_OPERATORS.includes? name
        "operator #{name}"
      elsif ADDITIONAL_OPERATORS.has_key? name
        ADDITIONAL_OPERATORS[name]
      else
        name.sub(/^(.*)=$/) { |m| "set_#{m}" }
          .sub(/^(.*)\?$/) { |m| "is_#{m}" }
          .sub(/^(.*)!$/) { |m| "#{m}_" }
          .gsub(/[!\?=@]/, "")
      end
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
