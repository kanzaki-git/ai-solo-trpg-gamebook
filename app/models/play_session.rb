class PlaySession < ApplicationRecord
  belongs_to :user
  belongs_to :gamebook
  belongs_to :current_scene,
             class_name: "Scene"
  belongs_to :ending_scene,
             class_name: "Scene",
             optional: true

  has_many :play_session_flags,
           dependent: :destroy
  has_many :flags,
           through: :play_session_flags

  has_many :play_session_items,
           dependent: :destroy
  has_many :items,
           through: :play_session_items

  has_many :play_histories,
           dependent: :destroy

  enum :status, {
    playing: 0,
    completed: 1,
    abandoned: 2
  }

  validates :started_at, presence: true
end
