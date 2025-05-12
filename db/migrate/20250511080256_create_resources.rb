class CreateResources < ActiveRecord::Migration[8.0]
  def change
    create_table :resources, id: :uuid do |t|
      t.string :slug
      t.string :name
      t.text :description
      t.string :label
      t.string :kind # Replaced `type` with `kind` for clarity and to avoid conflicts
      t.string :value # Column to store additional resource information
      t.string :created_by
      t.string :updated_by

      t.timestamps
    end
  end
end
