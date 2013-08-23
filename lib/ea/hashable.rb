module EA
  module Hashable
    def as_hash
      ret = {}
      self.instance_variables.each do |var|
        k = var.to_s.gsub('@','').to_sym
        val = instance_variable_get(var)
        if val.is_a?(Array) && val.first.try(:respond_to?, :as_hash)
          ret[k] = val.map(&:as_hash)
        else
          ret[k] = val
        end
      end
      ret
    end
  end
end