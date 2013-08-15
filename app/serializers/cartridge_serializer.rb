class CartridgeSerializer < ActiveModel::Serializer
  attributes :uid, :name, :data, :created_at, :updated_at
end