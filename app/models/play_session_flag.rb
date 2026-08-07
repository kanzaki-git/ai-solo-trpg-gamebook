class PlaySessionFlag < ApplicationRecord
  belongs_to :play_session
  belongs_to :flag

  validates :flag_id,
            uniqueness: { scope: :play_session_id }
end
