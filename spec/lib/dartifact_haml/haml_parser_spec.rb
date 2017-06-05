require "spec_helper"

describe DartifactHaml::Parser do

  def render(text)
    Haml::Engine.new(text, parser_class: DartifactHaml::Parser).to_html.rstrip
  end

  it "separates component part from the tag part" do
    expect(render("%%component_name%div hello")).to eq("<div>hello</div>")
  end

end
