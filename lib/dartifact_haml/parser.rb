module DartifactHaml
  class Parser < ::Haml::Parser

    def process_line(line)
      component_part = line.text.match(/\A%%.*?%/)[0]
      line.text = line.text.sub(/\A%%.*?%/, "%")
      super(line)
    end

  end
end
