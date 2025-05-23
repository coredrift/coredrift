class CreateRolePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :role_permissions, id: :uuid do |t|
      t.references :role, null: false, foreign_key: true, type: :uuid
      t.references :permission, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
