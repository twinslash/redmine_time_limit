class CreateTimers < ActiveRecord::Migration
  def self.up
    create_table :timers do |t|
      t.column :issue_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :start, :datetime
      t.column :hours, :float, :null => false
    end
  end

  def self.down
    drop_table :timers
  end
end
