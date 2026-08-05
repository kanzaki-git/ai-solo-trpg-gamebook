class CreateFlags < ActiveRecord::Migration[8.0]
  def change
    create_table :flags do |t|
      t.references :gamebook, null: false, foreign_key: true
      t.string :key, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end
