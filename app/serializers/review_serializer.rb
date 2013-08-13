class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :rating, :comments, :created_at, :user

  def user
    object.user.as_tiny_json
  end
end
