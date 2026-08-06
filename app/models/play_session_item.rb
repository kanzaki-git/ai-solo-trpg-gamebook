class PlaySessionItem < ApplicationRecord
  belongs_to :play_session
  belongs_to :item
end
