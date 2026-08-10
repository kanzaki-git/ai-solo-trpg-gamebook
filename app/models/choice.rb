class Choice < ApplicationRecord
  belongs_to :scene
  belongs_to :next_scene,
             class_name: "Scene"

  has_many :choice_flag_rules,
           dependent: :destroy

  has_many :choice_item_rules,
           dependent: :destroy

  has_many :play_histories,
           dependent: :restrict_with_error

  def available_for?(play_session)
    required_flag_ids = choice_flag_rules.required.pluck(:flag_id)

    (required_flag_ids - play_session.flag_ids).empty?
  end
end
