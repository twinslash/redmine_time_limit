require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

class WhenPluginActivate < ActionDispatch::IntegrationTest
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :enumerations,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers

  test "time limit indicator should be available" do
    user_login

    get '/my/page'
    assert_response :success
    assert_select 'div#time_limit_indicator'
  end

  test 'time entry without permisions' do
    disable_permissions(2)
    user_login
    set_time_limit(User.current)

    put_time('/issues/1', 1)
    assert_response 302

    put_time('/issues/1', 25)
    assert_response 200
    assert_select 'div#errorExplanation'
  end

  test 'time entry with permisions' do
    user_login

    enable_permissions(2)
    put_time('/issues/1', 25)
    assert_response 302

    enable_no_time_limit_permissions(2)
    put_time('/issues/1', 25)
    assert_response 302

    enable_edit_own_time_entries_permissions(2)
    put_time('/issues/1', 25)
    assert_response 302
  end

  private

    def user_login
      log_user('dlopper', 'foo')
      get '/issues/1'
      assert_response :success
    end

    def set_time_limit(usr)
      usr.time_limit_hours = -3.0
      usr.save!
    end

    def put_time(url, time)
          put url, :time_entry => {
                :hours => time,
                :activity_id => 8,
                :comments => "//"}
    end

    def disable_permissions(role_id)
      Role.find(role_id).remove_permission! :edit_own_time_entries
      Role.find(role_id).remove_permission! :no_time_limit
    end

    def enable_no_time_limit_permissions(role_id)
      Role.find(role_id).remove_permission! :edit_own_time_entries
      Role.find(role_id).add_permission! :no_time_limit
    end

    def enable_edit_own_time_entries_permissions(role_id)
      Role.find(role_id).add_permission! :edit_own_time_entries
      Role.find(role_id).remove_permission! :no_time_limit
    end

    def enable_permissions(role_id)
      Role.find(role_id).add_permission! :edit_own_time_entries
      Role.find(role_id).add_permission! :no_time_limit
    end
end
