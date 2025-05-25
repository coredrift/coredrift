class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs, id: :uuid do |t|
      t.string :job_type, null: false
      t.references :target, null: false, type: :uuid, index: true
      t.datetime :scheduled_for, null: false
      t.string :state, null: false, default: "pending"
      t.datetime :executed_at
      t.text :error_message
      t.timestamps
    end
    add_index :jobs, [ :job_type, :target_id, :scheduled_for ], unique: true
  end
end
