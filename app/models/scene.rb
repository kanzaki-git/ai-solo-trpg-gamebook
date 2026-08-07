class Scene < ApplicationRecord
  belongs_to :gamebook

  enum :scene_type, {
    introduction: 0,
    exploration: 1,
    change: 2,
    summary: 3,
    climax: 4,
    ending: 5
  }

  enum :ending_type, {
    bad: 0,
    normal: 1,
    true: 2
  }

  has_many :choices,
           dependent: :destroy

  has_many :incoming_choices,
           class_name: "Choice",
           foreign_key: :next_scene_id,
           dependent: :restrict_with_error

  has_many :current_play_sessions,
           class_name: "PlaySession",
           foreign_key: :current_scene_id,
           dependent: :restrict_with_error

  has_many :ending_play_sessions,
           class_name: "PlaySession",
           foreign_key: :ending_scene_id,
           dependent: :restrict_with_error

  has_many :play_histories,
           dependent: :restrict_with_error
end
