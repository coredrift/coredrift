class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :slug
      t.string :name
      t.text :description
      t.boolean :contextual, default: false, null: false
      t.string :status
      t.string :created_by
      t.string :updated_by

      t.timestamps
    end
  end
end
