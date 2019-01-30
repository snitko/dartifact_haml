module WebfaceHaml
  class Parser < ::Haml::Parser

    def process_line(haml_line)
      component_part_string = haml_line.text.match(/\A%%.*?%/)[0]
      haml_line.text        = haml_line.text.sub(/\A%%.*?%/, "%")

      if component_part_string
        haml_line.text = add_component_data_to_tag(component_part_parsed(component_part_string), haml_line.text)
      end

      super(haml_line)
    end

    # Parses component_part string, creating a hash with
    # each Component logical element content and a method to be called
    # to insert this content into the tag.
    #
    # Input.:  component_part_string = "form_field(country_selector,selector)"
    # Result: { name: "FormField", roles: "country_selector,selector" }
    def component_part_parsed(string)
      matches = string.chomp("%").match(/%%([:a-zA-Z0-9_]+)?\s*(\(.*?\))?\s*(\(.*?\))?\s*(\{.*\})?/)

      parsed = {}

      if matches[1].start_with?(":")
        parsed[:part] = matches[1].sub(/\A:/, "")
      elsif !matches[1].nil?
        if(matches[1].to_s.include?("_") || matches[1][0] != matches[1][0].upcase)
          parsed[:name] = matches[1].split('_').collect(&:capitalize).join + "Component"
        else
          parsed[:name] = matches[1] + "Component"
        end
      end

      parsed[:roles]                = matches[2].gsub(/[\(\)]/, "") if matches[2]
      parsed[:property]             = matches[3].gsub(/[\(\)]/, "") if matches[3]
      parsed[:attribute_properties] = matches[4].gsub(/[\{\}]/, "") if matches[4]

      parsed
    end

    # Modifies the original haml tag adding necessary data- attributes to indicate
    # this is a component.
    #
    # Input: component_part_parsed = "form_field(country_selector,selector)"
    #        haml_line             = "%input(name="country")
    #
    # Result: "%input(name="country"
    #                 data-component-name="FormFieldComponent"
    #                 data-component-roles="country_selector,selector")
    def add_component_data_to_tag(component_part_parsed, haml_text)

      # Parsing haml so we can later reconstruct it and insert our own
      # attributes.
      matches     = haml_text.match(/%([a-zA-Z0-9_#.\-]+)?\s*(\(.+\))?\s*(\{.+\})?(.*)/)
      tag         = matches[1] || "div"
      tag         = "div#{tag}" if tag.match(/\A[.#]/)
      attrs_plain = matches[2] ? matches[2].gsub(/[\(\)]/, "") : ""
      attrs_curly = matches[3] ? matches[3].gsub(/[\{\}]/, "") : ""
      remainder   = matches[4]

      component_part_parsed.each do |attr_name,value|

        # Turns attribute_properties passed into appropriate data- attributes.
        # Example:
        #   Passed:                 { attr_1: "value1", attr_2: "value2" }
        #
        #   Result (inside a tag) : data-component-property-attributes="attr_1:data-attr-1,attr_2:data-attr-2"
        #                           data-attr-1="value1"
        #                           data-attr-2="value2"
        if attr_name == :attribute_properties
          attribute_properties = []
          parse_attribute_properties_hash(value).each do |k,v|
            if(k =~ /\A.+\(.*\)\Z/)
              _attrs = k.split('(')
              webface_attr_name = _attrs[0]
              html_attr_name    = _attrs[1].chomp(")")
            else
              webface_attr_name = k
              html_attr_name    = "data-#{k}"
            end
            attrs_plain += " #{html_attr_name}=\"#{v}\"" if v
            attribute_properties << "#{webface_attr_name}:#{html_attr_name.gsub("_", "-")}"
          end
          attrs_plain += " data-component-#{attr_name.to_s.gsub("_", "-")}=\"#{attribute_properties.join(",")}\""

        # Take care of the rest of component data- attributes, such as
        # data-component-name, data-component-roles and data-component-property
        else
          attrs_plain += " data-component-#{attr_name.to_s.gsub("_", "-")}=\"#{value}\""
        end
      end

      "%#{tag}(#{attrs_plain.lstrip}){#{attrs_curly}} #{remainder}".rstrip
    end

    # Attribute properties are passed as in a format that mirrors Ruby Hash. Example:
    # { attribute1: "value1", attribute2: "value2" }.
    # This method parses the string and turns it into an actual Ruby Hash.
    def parse_attribute_properties_hash(s)
      hash = {}
      s.split(",").map { |i| i.lstrip!; i.rstrip }.each do |i|
        k,v= i.split(/\s*:\s*/)
        hash[k] = v ? v.gsub(/["'](.*)["']/, '\1') : nil
      end
      hash
    end


  end
end
