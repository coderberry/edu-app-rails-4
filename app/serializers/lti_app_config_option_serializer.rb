class LtiAppConfigOptionSerializer < ActiveModel::Serializer
  attributes :name, :param_type, :default_value, :description, :is_required
end