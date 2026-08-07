class ChoiceItemRule < ApplicationRecord
  belongs_to :choice
  belongs_to :item

  enum :rule_type, {
    required: 0,
    add: 1,
    remove: 2
  }

  validates :rule_type, presence: true
  validates :item_id,
            uniqueness: { scope: [ :choice_id, :rule_type ] }
end
