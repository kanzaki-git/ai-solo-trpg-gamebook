class Gamebook < ApplicationRecord
  belongs_to :user

  has_many :items, dependent: :destroy
  has_many :play_sessions, dependent: :destroy
end
