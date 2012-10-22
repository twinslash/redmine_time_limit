class AddUserTimeLimit < ActiveRecord::Migration
  def self.up
    add_column :users, :time_limit_begin, :datetime
    add_column :users, :time_limit_hours, :float
  end

  def self.down
    remove_column :users, :time_limit_begin
    remove_column :users, :time_limit_hours
  end
end
