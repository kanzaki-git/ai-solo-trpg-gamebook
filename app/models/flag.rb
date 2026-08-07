class Flag < ApplicationRecord
  belongs_to :gamebook

  has_many :choice_flag_rules,
           dependent: :destroy

  has_many :play_session_flags,
           dependent: :destroy
end
