class AddUniqueIndexesToPlaySessionFlagsAndItems < ActiveRecord::Migration[8.0]
  def change
    add_index :play_session_flags,
              [ :play_session_id, :flag_id ],
              unique: true

    add_index :play_session_items,
              [ :play_session_id, :item_id ],
              unique: true
  end
end
