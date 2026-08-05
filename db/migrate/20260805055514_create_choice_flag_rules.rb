class CreateChoiceFlagRules < ActiveRecord::Migration[8.0]
  def change
    create_table :choice_flag_rules do |t|
      t.references :choice, null: false, foreign_key: true
      t.references :flag, null: false, foreign_key: true
      t.integer :rule_type, null: false

      t.timestamps
    end
  end
end
