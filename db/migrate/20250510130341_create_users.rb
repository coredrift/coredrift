class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string   :email_address,   null: false
      t.string   :password_digest, null: false
      t.string   :username
      t.string   :slug
      t.datetime :last_login_at
      t.string   :last_login_ip
      t.boolean  :is_active,       default: true, null: false
      t.string   :created_by
      t.string   :updated_by
      t.integer  :session_stamp, default: 0, null: false

      t.timestamps
    end

    add_index :users, :email_address, unique: true
    add_index :users, :username,      unique: true
    add_index :users, :slug,          unique: true
  end
end
