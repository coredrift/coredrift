class CreateUserRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_roles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :role, null: false, foreign_key: true, type: :uuid
      t.string :context_type
      t.string :context_id, index: true
      t.timestamps
    end
  end
end
