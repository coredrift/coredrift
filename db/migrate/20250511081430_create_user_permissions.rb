class CreateUserPermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :user_permissions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :permission, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
