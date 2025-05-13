class CreateTeams < ActiveRecord::Migration[6.1]
  def change
    create_table :teams, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :slug, null: false, index: { unique: true }
      t.string :name, null: false
      t.text   :description

      t.timestamps
    end
  end
end