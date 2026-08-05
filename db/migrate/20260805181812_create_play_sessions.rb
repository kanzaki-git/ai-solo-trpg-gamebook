class CreatePlaySessions < ActiveRecord::Migration[8.0]
  def change
    create_table :play_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :gamebook, null: false, foreign_key: true

      t.references :current_scene,
                   null: false,
                   foreign_key: { to_table: :scenes }

      t.references :ending_scene,
                   null: true,
                   foreign_key: { to_table: :scenes }

      t.integer :status, null: false, default: 0
      t.datetime :started_at, null: false
      t.datetime :completed_at

      t.timestamps
    end
  end
end
