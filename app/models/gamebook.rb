class Gamebook < ApplicationRecord
  belongs_to :user

  has_many :scenes, dependent: :destroy
  has_many :flags, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :play_sessions, dependent: :destroy

  enum :generation_status, {
    generating: 0,
    completed: 1,
    failed: 2
  }

  validates :genre, presence: true
  validates :world_setting, presence: true
  validates :tone, presence: true
  validates :difficulty, presence: true
  validates :play_time,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }
end
