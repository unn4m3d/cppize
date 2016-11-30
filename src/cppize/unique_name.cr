module Cppize
  class Transpiler
    @unique_counter = 0u64
    def unique_name
      @unique_counter += 1
      "__temp_#{@unique_counter}_"
    end
  end
end
