class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :slug, index: { unique: true }
      t.string :email_address, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :username, index: { unique: true }
      t.string :name
      t.datetime :last_login_at
      t.string :last_login_ip
      t.boolean :is_active, null: false, default: true
      t.integer :session_stamp, null: false, default: 0
      t.string :created_by
      t.string :updated_by
      t.string :role, null: false, default: 'member'
      t.timestamps
    end
  end
end
