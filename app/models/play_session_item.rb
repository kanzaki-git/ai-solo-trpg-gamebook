class PlaySessionItem < ApplicationRecord
  belongs_to :play_session
  belongs_to :item

  validates :item_id,
            uniqueness: { scope: :play_session_id }
end
