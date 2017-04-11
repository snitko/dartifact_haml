module DartifactHaml
  class Parser < ::Haml::Parser

    def process_line(line)
      line.text = line.text + "!"
      super(line)
    end

  end
end
