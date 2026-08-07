class ChoiceFlagRule < ApplicationRecord
  belongs_to :choice
  belongs_to :flag

  enum :rule_type, {
    required: 0,
    add: 1,
    remove: 2
  }

  validates :rule_type, presence: true
  validates :flag_id,
            uniqueness: { scope: [ :choice_id, :rule_type ] }
end
