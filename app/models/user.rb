class User
  extend ActiveModel::Naming
  include ActiveModel::Serialization
  extend ActiveModel::Translation

  attr_reader :id, :email, :email_verified

  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access
    @id = attributes[:id]
    @email = attributes[:email]
    @email_verified = attributes[:email_verified]
  end
end
