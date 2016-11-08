module Cppize
  class Transpiler
    protected def transpile(node : Crystal::FunDef, r : Bool = false)
      try_tr node do
        args = node.args.map do |arg|
          "#{transpile arg.restriction} #{arg.name}"
        end.join(", ")

        _type = transpile node.return_type

        _type += "::unsafe_type" unless (_type == "void" || options.has_key?("primitive-types"))

        if node.name == node.real_name
          "extern \"C\" #{_type} #{transpile node.real_name}(#{args})"
        else
          Lines.new @failsafe do |l|
            l.block "namespace __fun_def_pseudonyms" do
              l.line "extern \"C\" #{_type} #{transpile node.real_name}(#{args})"
            end

            l.block "auto #{node.name}(#{args})" do
              l.line "return __fun_def_pseudonyms::#{node.real_name}(#{node.args.map &.name})"
            end
          end.to_s
        end
      end
    end
  end
end
