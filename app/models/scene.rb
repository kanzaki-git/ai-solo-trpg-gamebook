class Scene < ApplicationRecord
  belongs_to :gamebook

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
