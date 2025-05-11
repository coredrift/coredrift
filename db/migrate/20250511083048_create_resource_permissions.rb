class CreateResourcePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :resource_permissions, id: :uuid do |t|
      t.references :resource, null: false, foreign_key: true, type: :uuid
      t.references :permission, null: false, foreign_key: true, type: :uuid
      t.string :created_by

      t.timestamps
    end
  end
end
