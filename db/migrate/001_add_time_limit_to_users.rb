class AddTimeLimitToUsers < ActiveRecord::Migration
  def change
    add_column :users, :time_limit_begin, :datetime
    add_column :users, :time_limit_hours, :float
  end
end
