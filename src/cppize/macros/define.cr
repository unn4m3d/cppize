module Cppize
  class Transpiler
    property defines

    @defines = Array(String).new
    add_macro(:define) do |_self, call|
      if _self.use_preprocessor_defs?
        Lines.new do |l|
          call.args.each do |arg|
            if arg.responds_to? :value
              l.line "#define #{arg.value.to_s}", true
            else
              _self.warning "Only literals should be passed to define",call,nil,_self.current_filename
              l.line "#define #{arg.to_s}", true
            end
          end
        end
      else
        call.args.each do |arg|
          if arg.responds_to? :value
            _self.defines.push arg.value.to_s
          else
            _self.warning "Only literals should be passed to define",call,nil,_self.current_filename
            _self.defines.push arg.to_s
          end
        end
      end
      ""
    end

    add_macro(:undef) do |_self, call|
      if _self.use_preprocessor_defs?
        Lines.new do |l|
          call.args.each do |arg|
            if arg.responds_to? :value
              l.line "#undef #{arg.value.to_s}", true
            else
              _self.warning "Only literals should be passed to undef",call,nil,_self.current_filename
              l.line "#undef #{arg.to_s}", true
            end
          end
        end
      else
        call.args.each do |arg|
          if arg.responds_to? :value
            _self.defines.delete arg.value.to_s
          else
            _self.warning "Only literals should be passed to undef",call,nil,_self.current_filename
            _self.defines.delete arg.to_s
          end
        end
      end
      ""
    end
  end
end
