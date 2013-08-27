module EA
  class Cartridge
    include Hashable
    attr_accessor :title, :description, :iconUrl, :launchUrl, :toolId, :defaultLinkText, :defaultWidth,
                  :defaultHeight, :launchPrivacy, :domain, :editorButton, :resourceSelection,
                  :homeworkSubmission, :courseNav, :accountNav, :userNav
    attr_accessor :customFields, :configOptions

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
      @customFields  ||= []
      @configOptions ||= []
    end

    def as_json
      self.as_hash.to_json
    end
  end
end