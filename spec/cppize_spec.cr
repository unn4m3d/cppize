require "./spec_helper"

describe Cppize do
  # TODO: Write tests

  it "works" do
    begin
      Cppize::Transpiler.new(false).parse_and_transpile("puts 0","test")
      true.should eq(true)
    rescue ex
      ex.should eq("")
    end
  end
end
