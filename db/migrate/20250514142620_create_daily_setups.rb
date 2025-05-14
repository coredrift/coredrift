class CreateDailySetups < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_setups, id: :uuid do |t|
      t.references :team, null: false, foreign_key: true, type: :uuid, index: { unique: true }

      t.string :slug, null: false, index: { unique: true }
      t.string :name, null: false
      t.text   :description

      t.string  :visible_at, null: false, default: "09:30"
      t.string  :reminder_at, null: false, default: "09:00"
      t.string  :daily_report_time, null: false, default: "10:00"
      t.string  :weekly_report_day, null: false, default: "fri"
      t.string  :weekly_report_time, null: false, default: "17:00"
      t.string  :template, null: false, default: "freeform"
      t.boolean :allow_comments, null: false, default: false
      t.boolean :active, null: false, default: true
      t.json    :settings, null: false, default: {}

      t.timestamps
    end
  end
end
