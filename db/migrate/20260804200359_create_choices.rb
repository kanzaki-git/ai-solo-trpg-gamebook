class CreateChoices < ActiveRecord::Migration[8.0]
  def change
    create_table :choices do |t|
      t.references :scene, null: false, foreign_key: true
      t.references :next_scene, null: false,
                                foreign_key: { to_table: :scenes }
      t.string :text, null: false
      t.text :result_text, null: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end
