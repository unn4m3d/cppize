module Cppize
  class Transpiler
    add_macro(:__cppize_version__) do |_self, call|
      StringLiteral.new(VERSION).stringify.to_s
    end
  end
end
