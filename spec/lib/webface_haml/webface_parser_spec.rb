require "spec_helper"

describe WebfaceHaml::Parser do

  def render(text)
    Haml::Engine.new(text, parser_class: WebfaceHaml::Parser).render.rstrip
  end

  context "parser methods" do

    before(:each) do
      @parser = WebfaceHaml::Parser.new([])
    end

    it "parses the component part of the haml line" do
      result = @parser.component_part_parsed("%%form_field(country_selector,selector)")
      expect(result).to eq({ name: "FormFieldComponent", roles: "country_selector,selector" })
    end

    it "inserts roles into the component-related attributes in the original haml" do
      result = @parser.add_component_data_to_tag({ name: "FormFieldComponent", roles: "country_selector,selector" }, '%div(align="left")')
      expect(result).to eq('%div(align="left" data-component-name="FormFieldComponent" data-component-roles="country_selector,selector"){}')
    end

    it "inserts component attribute properties and their values into the component-related attributes in the original haml" do
      result = @parser.add_component_data_to_tag({ name: "FormFieldComponent", attribute_properties: 'hello: "world"'}, '%div(align="left")')
      expect(result).to eq('%div(align="left" data-component-name="FormFieldComponent" data-hello="world" data-component-attribute-properties="hello:data-hello"){}')
    end

    it "inserts component part attributes into the component-related attributes in the original haml" do
      result = @parser.add_component_data_to_tag({ part: "input_field" }, '%input')
      expect(result).to eq('%input(data-component-part="input_field"){}')
    end

  end

  it "adds component name as data attribute to the tag" do
    expect(render("%%DialogWindow%div hello")).to eq("<div data-component-name='DialogWindowComponent'>hello</div>")
  end

  it "adds part name as data attribute to the tag" do
    expect(render("%%:input_field%input")).to eq("<input data-component-part='input_field'>")
  end

  it "adds roles as data attributes to the tag" do
    expect(render("%%:input_field(role1,role2)%input")).to eq("<input data-component-part='input_field' data-component-roles='role1,role2'>")
  end

  it "adds property data attribute to the tag" do
    expect(render("%%:input_field(role1,role2)(property1)%.input")).to eq("<div class='input' data-component-part='input_field' data-component-property='property1' data-component-roles='role1,role2'></div>")
  end

  it "adds attribute properties data attribute to the component tag" do
    expect(render("%%button{ value: 'click' }%div")).to eq("<div data-component-attribute-properties='value:data-value' data-component-name='ButtonComponent' data-value='click'></div>")
  end

  it "adds attribute properties that have a different name as html attributes" do
    expect(render("%%button{ value(data-val): 'click' }%div")).to eq("<div data-component-attribute-properties='value:data-val' data-component-name='ButtonComponent' data-val='click'></div>")
  end

  it "adds attribute into attribute properties names, but not values" do
    expect(render("%%button{ value(data-val) }%div")).to eq("<div data-component-attribute-properties='value:data-val' data-component-name='ButtonComponent'></div>")
  end

  it "allows to skip tag name" do
    expect(render("%%button%.button hello")).to eq("<div class='button' data-component-name='ButtonComponent'>hello</div>")
  end

end
