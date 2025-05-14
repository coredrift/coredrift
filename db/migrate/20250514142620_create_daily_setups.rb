create_table :daily_setups, id: :uuid do |t|
  t.uuid   :team_id,             null: false
  t.string :slug,                null: false, index: { unique: true }
  t.string :name,                null: false
  t.text   :description
  t.string :visible_at,          null: false, default: "09:30" 
  t.string :reminder_at,         null: false, default: "09:00"
  t.string :daily_report_time, null: false, default: "10:00"
  t.string :weekly_report_day,   null: false, default: "fri"
  t.string :weekly_report_time,  null: false, default: "17:00"
  t.string :template,            null: false, default: "freeform"
  t.boolean :allow_comments,     null: false, default: false
  t.boolean :active,             null: false, default: true
  t.jsonb  :settings,            null: false, default: {}
  t.timestamps
end

add_foreign_key :daily_setups, :teams
add_index :daily_setups, :team_id, unique: true
