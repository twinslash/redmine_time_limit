class CreateTimer < ActiveRecord::Migration
  def change
    create_table :timers do |t|
      t.integer  :user_id
      t.integer  :issue_id
      t.datetime :started_at
      t.datetime :stopped_at
      t.integer  :spent

      t.timestamps
    end
  end
end
