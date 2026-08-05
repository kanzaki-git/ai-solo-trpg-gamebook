class PlaySession < ApplicationRecord
  belongs_to :user
  belongs_to :gamebook
  belongs_to :current_scene, class_name: "Scene"
  belongs_to :ending_scene, class_name: "Scene", optional: true

  enum :status, {
    playing: 0,
    completed: 1,
    abandoned: 2
  }

  validates :started_at, presence: true
end
