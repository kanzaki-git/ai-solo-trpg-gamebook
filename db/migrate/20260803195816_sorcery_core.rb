class SorceryCore < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name,             null: false
      t.string :email,            null: false, index: { unique: true }
      t.string :crypted_password, null: false
      t.string :salt,             null: false

      t.timestamps                null: false
    end
  end
end
