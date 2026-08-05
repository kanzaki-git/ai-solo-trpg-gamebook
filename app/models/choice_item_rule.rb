class ChoiceItemRule < ApplicationRecord
  belongs_to :choice
  belongs_to :item

  enum :rule_type, {
    required: 0,
    add: 1,
    remove: 2
  }
end
