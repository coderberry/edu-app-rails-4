class TagSerializer < ActiveModel::Serializer
  attributes :id, :short_name, :name, :context
end
