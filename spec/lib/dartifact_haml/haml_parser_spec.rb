require "spec_helper"

describe DartifactHaml::Parser do

  def render(text)
    Haml::Engine.new(text, parser_class: DartifactHaml::Parser).to_html.rstrip
  end

  describe "parser methods" do

    before(:each) do
      @parser = DartifactHaml::Parser.new([])
    end


    it "parses the component part of the haml line" do
      result = @parser.component_part_parsed("%%form_field(country_selector,selector)")
      expect(result).to eq({ name: "FormFieldComponent", roles: "country_selector,selector" })
    end

    it "inserts component-related attributes into the original haml" do
      result = @parser.add_component_data_to_tag({ name: "FormFieldComponent", roles: "country_selector,selector" }, '%div(align="left")')
      expect(result).to eq('%div(align="left" data-component-name="FormFieldComponent" data-component-roles="country_selector,selector"){}')
    end

    it "inserts component attribute properties and their values" do
      result = @parser.add_component_data_to_tag({ name: "FormFieldComponent", attribute_properties: 'hello: "world"'}, '%div(align="left")')
      expect(result).to eq('%div(align="left" data-component-name="FormFieldComponent" data-hello="world" data-component-attribute-properties="hello:data-hello"){}')
    end


  end

  it "adds component name as a data attribute to the tag" do
    expect(render("%%button%div hello")).to eq("<div data-component-name='ButtonComponent'>hello</div>")
  end

end
