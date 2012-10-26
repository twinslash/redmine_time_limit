require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

class WhenPluginActivate < ActionDispatch::IntegrationTest
  fixtures :projects,
           :users,
           :roles,
           :members,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :issue_statuses,
           :issues,
           :enumerations,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers

  test "time limit indicator should be available" do
    get "/login"
    assert_response :success

    post_via_redirect '/login', :username => users(:users_001).login,
                                :password => 'admin'

    assert_equal '/my/page', path
    assert_select 'div#time_limit_indicator'
  end

  # test "time limit insert fixtures" do
  #   log_user("admin", "admin")
  # end

  test "test add issue" do
    log_user('rhill', 'foo')
    get '/projects/1'
    assert_response :success

    get '/projects/1/issues/new', :tracker_id => '1'
    assert_response :success
    assert_template 'issues/new'

    post 'projects/1/issues', :tracker_id => "1",
                                 :issue => { :start_date => "2006-12-26",
                                             :priority_id => "4",
                                             :subject => "new test issue",
                                             :category_id => "",
                                             :description => "new issue",
                                             :done_ratio => "0",
                                             :due_date => "",
                                             :assigned_to_id => "" },
                                 :custom_fields => {'2' => 'Value for field 2'}
    # find created issue
    issue = Issue.find_by_subject("new test issue")
    assert_kind_of Issue, issue

    # check redirection
    assert_redirected_to :controller => 'issues', :action => 'show', :id => issue
    follow_redirect!
    assert_equal issue, assigns(:issue)

    # check issue attributes
    assert_equal 'rhill', issue.author.login
    assert_equal 1, issue.project.id
    assert_equal 1, issue.status.id
  end

  test "update_issue" do
    log_user('rhill', 'foo')
    get "/issues/#{Issue.first.id}"
    assert_response :success

    put "/issues/#{Issue.first.id}", :notes => 'Lorem ipsum dollor'
    assert_response 302
    assert_equal "/issues/#{Issue.first.id}", path
    get "/issues/#{Issue.first.id}"
    assert_select 'p', 'Lorem ipsum dollor'
    p '111'
  end

  test "update issue log time" do
    log_user('admin', 'admin')
    get "/issues/#{Issue.first.id}"
    assert_response :success

    p User.current

    put_via_redirect "/issues/#{Issue.first.id}",
      {:issue => {
        :is_private => "0",
        :tracker_id => "1",
        :subject => "Issue 03",
        :description => "",
        :status_id => "3",
        :priority_id => "2",
        :assigned_to_id => "",
        :parent_issue_id => "",
        :start_date => "2012-10-26",
        :due_date => "",
        :estimated_hours => "",
        :done_ratio => "0",
        :lock_version => "3"},
      :time_entry => {
        :hours => 99.01,
        :activity_id => 8,
        :comments => "//"},
      :notes => "",
      :attachments => {
        "1" => {
          :description => ""}},
      :last_journal_id => "4",
      :commit => "Submit",
      :id => "3"}

    assert_response 200
    assert_select 'div#errorExplanation'

    p User.current
  end

  def boo
    p User.current
  end
end
