match "/issues/:id/start_timer" => "issues#start_timer", :as => :start_timer
match "/issues/:id/stop_timer" => "issues#stop_timer", :as => :stop_timer
match 'day_reports', :to => 'day_reports#index', :via => [:get, :post]
