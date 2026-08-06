class PlayHistory < ApplicationRecord
  belongs_to :play_session
  belongs_to :scene
  belongs_to :choice, optional: true
end
