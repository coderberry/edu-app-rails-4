class CartridgeSerializer < ActiveModel::Serializer
  attributes :uid, :name, :xml, :created_at, :updated_at
end