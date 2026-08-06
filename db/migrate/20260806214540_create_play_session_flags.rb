class CreatePlaySessionFlags < ActiveRecord::Migration[8.0]
  def change
    create_table :play_session_flags do |t|
      t.references :play_session, null: false, foreign_key: true
      t.references :flag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
