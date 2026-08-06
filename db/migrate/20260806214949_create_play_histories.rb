class CreatePlayHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :play_histories do |t|
      t.references :play_session, null: false, foreign_key: true
      t.references :scene, null: false, foreign_key: true
      t.references :choice, null: true, foreign_key: true
      t.datetime :visited_at, null: false

      t.timestamps
    end
  end
end
