class AuthorSerializer < ActiveModel::Serializer
  attributes :id, :name, :discount, :biography
  has_many :books
  has_many :published
end
