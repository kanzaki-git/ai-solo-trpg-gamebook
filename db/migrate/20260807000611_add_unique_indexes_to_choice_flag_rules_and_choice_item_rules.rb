class AddUniqueIndexesToChoiceFlagRulesAndChoiceItemRules < ActiveRecord::Migration[8.0]
  def change
    add_index :choice_flag_rules,
              [ :choice_id, :flag_id, :rule_type ],
              unique: true

    add_index :choice_item_rules,
              [ :choice_id, :item_id, :rule_type ],
              unique: true
  end
end
