module Cppize
  class Transpiler
    register_node EnumDef do
      if node.base_type
        raise Error.new("Only enums without base type are supported",node,nil,@current_filename)
      end

      Lines.new(@failsafe) do |l|
        l.line "// Generated from #{node.name}", true
        l.block("enum class #{transpile node.name}") do
          node.members.each do |member|
            if member.responds_to? :name
              l.line(member.name.to_s + ",", true)
            end
          end
        end
      end.to_s + ";"
    end
  end
end
