class User < ApplicationRecord
  validates :ip, presence: true
  has_many :search_queries, dependent: :destroy
end
