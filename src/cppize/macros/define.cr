module Cppize
  class Transpiler
    property defines

    @defines = Array(String).new
    add_macro(:define) do |_self, call|
      if _self.use_preprocessor_defs?
        Lines.new do |l|
          call.args.each do |arg|
            l.line "#define #{arg.to_s}", true
          end
        end
      else
        call.args.each { |arg| _self.defines.push arg.to_s }
      end
      ""
    end

    add_macro(:undef) do |_self, call|
      if _self.use_preprocessor_defs?
        Lines.new do |l|
          call.args.each do |arg|
            l.line "#undef #{arg.to_s}", true
          end
        end
      else
        call.args.each { |arg| _self.defines.delete arg.to_s }
      end
      ""
    end
  end
end
