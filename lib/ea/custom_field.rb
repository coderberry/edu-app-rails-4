module EA
  class CustomField
    include Hashable
    attr_accessor :name, :value

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
    end
  end
end