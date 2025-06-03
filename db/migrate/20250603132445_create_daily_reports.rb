class CreateDailyReports < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_reports, id: :uuid do |t|
      t.references :daily_setup, null: false, type: :uuid, foreign_key: true
      t.references :team, null: false, type: :uuid, foreign_key: true
      t.date :date, null: false
      t.string :status, null: false, default: 'active'
      t.datetime :published_at
      
      t.timestamps
    end

    add_index :daily_reports, [:daily_setup_id, :date], unique: true

    add_reference :dailies, :daily_report, type: :uuid, foreign_key: true, null: true
  end
end
