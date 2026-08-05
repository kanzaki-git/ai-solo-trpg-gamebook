class CreateChoiceItemRules < ActiveRecord::Migration[8.0]
  def change
    create_table :choice_item_rules do |t|
      t.references :choice, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :rule_type, null: false

      t.timestamps
    end
  end
end
