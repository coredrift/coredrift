class CreateDailies < ActiveRecord::Migration[8.0]
  def change
    create_table :dailies, id: :uuid do |t|
      t.references :team,        null: false, type: :uuid, foreign_key: true, index: true
      t.references :daily_setup, null: false, type: :uuid, foreign_key: true
      t.date     :date,               null: false
      t.datetime :visible_at,         null: false
      t.time     :reminder_at,        null: false
      t.time     :daily_report_time,  null: false
      t.timestamps
    end

    add_index :dailies, [:team_id, :date], unique: true
  end
end
