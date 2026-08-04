class CreateGamebooks < ActiveRecord::Migration[8.0]
  def change
    create_table :gamebooks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :summary
      t.string :genre
      t.text :world_setting
      t.string :tone
      t.string :difficulty
      t.integer :play_time
      t.integer :generation_status, null: false, default: 0
      t.string :openai_response_id
      t.text :generation_error_message
      t.datetime :generated_at

      t.timestamps
    end
  end
end
