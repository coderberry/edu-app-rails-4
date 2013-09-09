module EA
  class ConfigOptionTool
    attr_accessor :config_options, :params, :errors

    def initialize(opts, params={})
      opts ||= []
      @config_options = []
      @errors = {}
      @params = params
      opts.each do |opt|
        @config_options << ConfigOption.new(opt)
      end
    end

    def is_valid?
      @errors = {}
      required_params.each do |param_name|
        unless @params[param_name].present?
          @errors[param_name] = 'must be present'
        end
      end
      @errors.empty?
    end

    def sub(str)
      opts = self.options
      res = (str || '').gsub(/{{\s*escape:([\w_]+)\s*}}/) { |w| CGI.escape(opts[$1]) }
      res.gsub!(/{{\s*([\w_]+)\s*}}/) { |w| opts[$1] }
      res
    end

    def required_params
      @config_options.select {|co| co.is_required && co.default_value.blank? }.map(&:name)
    end

    def options
      opts = {}
      @config_options.each {|co| opts[co.name] = co.default_value }
      opts.each do |k,v|
        opts[k] = @params[k] if @params[k].present?
      end
      opts
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