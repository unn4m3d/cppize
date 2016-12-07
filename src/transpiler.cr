require "./cppize"
require "./colorize"

transpiler = Cppize::Transpiler.new false
code = ""
input = ""
use_stdin = false
output = nil
use_stdout = false
do_not_colorize = false
verbose = false

OptionParser.parse! do |opts|
  opts.banner = "Cppize v#{Cppize::VERSION}\n\nAvailable features :\n\t#{Cppize::Transpiler.features_list.map{|x| "-f#{x}"}.join("\n\t")} " +
    "\n\nAvailable warning types :\n\t#{Cppize.warning_list.map{|x| "-W#{x}"}.join("\n\t")}"

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

  opts.on("-d", "--preprocessor-defines", "Tells transpiler to use C preprocessor instead of internal conditional compilation system") do
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

  opts.on("-M","--monochrome","Do not colorize errors and warnings") do
    do_not_colorize = true
  end

  opts.on("-WWARNING","--warning WARNING","Enable warnings of given type") do |w|
    if w.strip == "all"
      transpiler.enabled_warnings = 0xFFFFFFFFFFFFFFFF
    elsif w.strip == "none"
      transpiler.enabled_warnings = 0u64
    else
      transpiler.enabled_warnings |= Cppize.warning_from_string w.strip.downcase
    end
  end

  opts.on("-V","--verbose","Run verbosely") do
    verbose = true
  end
end

if !do_not_colorize && !use_stdout
  transpiler.on_error do |e|
    puts e.to_s.colorize.fore(:red)
    exit 1
  end

  transpiler.on_warning do |e|
    if verbose
      puts e.to_s.colorize.fore(:yellow)
    else
      puts e.message.colorize.fore(:yellow)
    end
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

transpiler.post_initialize!

code += transpiler.parse_and_transpile(input_c,input)

if use_stdout
  puts code
else
  File.open(output.to_s, "w") { |f| f.puts(code) }
end
