module EA
  class Extension
    include Hashable
    attr_accessor :platform, :tool_id, :privacy_level, :domain, :default_link_text, :default_selection_width, :default_selection_height, :options

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
      @options ||= []
    end
  end
end