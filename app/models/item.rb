class Item < ApplicationRecord
  belongs_to :gamebook

  has_many :choice_item_rules,
           dependent: :destroy

  has_many :play_session_items,
           dependent: :destroy
end
