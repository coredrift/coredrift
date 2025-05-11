class CreatePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :permissions, id: :uuid do |t|
      t.string :slug
      t.string :name
      t.text :description
      t.string :created_by
      t.string :updated_by

      t.timestamps
    end
  end
end
