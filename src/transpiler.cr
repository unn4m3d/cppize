require "./cppize"

transpiler = Cppize::Transpiler.new
code = ""
input = ""
use_stdin = false
output = nil
use_stdout = false

OptionParser.parse! do |opts|
  opts.banner = "Cppize v#{Cppize::VERSION}"

  opts.on("-v", "--version", "Prints version and exits") do
    puts "#{Cppize::VERSION}"
    exit
  end

  opts.on("-D SYM", "--define SYM", "Defines preprocessor symbol SYM") do |s|
    if transpiler.use_preprocessor_defs?
      code += "#define #{s}\n"
    else
      transpiler.defines << s
    end
  end

  opts.on("-d", "--transpiler-defines", "Tells transpiler to use internal conditional compilation system instead of placing #define's in code") do
    transpiler.use_preprocessor_defs = true
  end

  opts.on("-f FEATURE", "--feature FEATURE", "Tells transpiler to use feature") do |f|
    fparts = f.split("=", 2)
    transpiler.options[fparts.first] = (fparts.size > 1 ? fparts[1] : "")
  end

  opts.on("-o OUT", "--output OUT", "Sets output file") do |o|
    output = o
    use_stdout = (o.strip == "-")
  end

  opts.on("-s", "--use-stdin", "Reads code from stdin") do
    use_stdin = true
    input = "<stdin>"
  end

  opts.on("-h", "--help", "Prints this help and exits") do
    puts opts
    exit
  end
end

unless use_stdin
  begin
    input = ARGV.shift
  rescue ex : IndexError
    raise Cppize::Transpiler::Error.new("No input specified") unless input
  end
end

def gets_to_end
  string = ""
  while line = gets
    string += line
  end
  string
end

input_c = ""
if use_stdin
  input_c = gets_to_end
else
  input_c = File.read(input)
end

unless output
  if use_stdin
    use_stdout = true
  else
    output = input.sub(/\.(cpp\.)?cr^/, ".gen.cpp")
  end
end

code += transpiler.parse_and_transpile(input_c,input )

if use_stdout
  puts code
else
  File.open(output.to_s, "w") { |f| f.puts(code) }
end
