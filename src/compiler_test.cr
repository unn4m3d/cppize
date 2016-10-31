require "./cppize"

puts Cppize::Transpiler.new(true).parse_and_transpile_file(ARGV[0])
