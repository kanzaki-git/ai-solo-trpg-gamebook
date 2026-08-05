class Item < ApplicationRecord
  belongs_to :gamebook
  has_many :choice_item_rules, dependent: :destroy
end
