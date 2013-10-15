module EA
  class ConfigOptionTool
    attr_accessor :config_options, :options, :errors

    def initialize(opts, params={})
      opts ||= []
      @config_options = []
      @errors = {}
      @config_options = opts

      @options = {}
      @config_options.each {|co| @options[co.name] = co.default_value }
      params.each {|k,v| @options[k] = v }

    end

    def is_valid?
      @errors = {}
      required_params.each do |param_name|
        unless @options[param_name].present?
          @errors[param_name] = 'must be present'
        end
      end
      @errors.empty?
    end

    def sub(str)
      return str unless str.class == String
      res = (str || '').gsub(/{{\s*escape:([\w_]+)\s*}}/) { |w| CGI.escape(@options[$1]) }
      res.gsub!(/{{\s*([\w_]+)\s*}}/) { |w| @options[$1] }
      res
    end

    def required_params
      @config_options.select {|co| co.is_required && co.default_value.blank? }.map(&:name)
    end
  end

  class MissingConfigOptionsError < StandardError
    attr_accessor :errors

    def initialize(message = nil, errors = {})
      super(message)
      self.errors = errors
    end
  end
end