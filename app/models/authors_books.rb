class AuthorsBooks < ApplicationRecord
  # Associations
  belongs_to :author
  belongs_to :book
end
