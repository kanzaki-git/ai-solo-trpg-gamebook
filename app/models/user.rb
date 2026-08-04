class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :gamebooks, dependent: :destroy

  attr_accessor :password_confirmation

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password,
            presence: true,
            length: { minimum: 8 },
            confirmation: true,
            if: -> { new_record? || password.present? }
  validates :password_confirmation,
            presence: true,
            if: -> { new_record? || password.present? }
end
