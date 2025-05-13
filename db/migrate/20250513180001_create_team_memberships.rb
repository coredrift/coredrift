class CreateTeamMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :team_memberships, id: :uuid do |t|
      t.references :team, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :relation_type, null: false, default: "direct"

      t.timestamps
    end

    add_index :team_memberships, [:team_id, :user_id], unique: true
  end
end