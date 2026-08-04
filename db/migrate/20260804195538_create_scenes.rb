class CreateScenes < ActiveRecord::Migration[8.0]
  def change
    create_table :scenes do |t|
      t.references :gamebook, null: false, foreign_key: true
      t.string :scene_key, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.text :situation, null: false
      t.integer :scene_type, null: false
      t.boolean :is_start, null: false, default: false
      t.boolean :is_ending, null: false, default: false
      t.integer :ending_type
      t.integer :position, null: false

      t.timestamps
    end
  end
end
