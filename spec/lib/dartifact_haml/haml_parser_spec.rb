require "spec_helper"

describe DartifactHaml::Parser do

  before(:each) do
    @parser = DartifactHaml::Parser.new(Haml::Options.new)
  end

  it "parses the line" do
    expect(@parser.call("hello world").children[0].value[:text]).to eq("hello world!")
  end

end
