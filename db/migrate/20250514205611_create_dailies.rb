class CreateDailies < ActiveRecord::Migration[8.0]
  def change
    create_table :dailies, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :team,        null: false, type: :uuid, foreign_key: true, index: true
      t.references :daily_setup, null: false, type: :uuid, foreign_key: true
      t.date     :date,               null: false
      t.datetime :visible_at,         null: false
      t.time     :reminder_at,        null: false
      t.time     :daily_report_time,  null: false

      t.text :freeform
      t.text :yesterday
      t.text :today
      t.text :blockers

      t.timestamps
    end

    add_index :dailies, [:team_id, :date], unique: true
    add_index :dailies, [:user_id, :date, :daily_setup_id], unique: true, name: 'index_dailies_on_user_date_setup'
  end
end
