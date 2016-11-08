require "./spec_helper"

describe Cppize do
  # TODO: Write tests

  it "works" do
    expect_raises(Cppize::Transpiler::Error) do
      Cppize::Transpiler.new(false).parse_and_transpile("nil.is_a? Nil","test")
    end
  end
end
