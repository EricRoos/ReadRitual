require "test_helper"

class HomescreenModalTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "test@example.com", password: "password123")
    sign_in @user
  end

  test "homescreen modal is shown for authenticated non-native users without cookie" do
    get root_path

    assert_response :success
    assert_includes response.body, "data-controller=\"homescreen-modal\""
    assert_includes response.body, "Get the App Experience!"
    assert_includes response.body, "Install"
    assert_includes response.body, "Read Ritual"
  end

  test "homescreen modal is not shown when cookie is set" do
    # Set the cookie to indicate the user has already seen the modal
    cookies[:homescreen_notification_shown] = "true"

    get root_path

    assert_response :success
    assert_not_includes response.body, "data-controller=\"homescreen-modal\""
    assert_not_includes response.body, "Get the App Experience!"
  end

  test "homescreen modal is not shown for native app requests" do
    get root_path, headers: { "User-Agent" => "ReadRitual Turbo Native App" }

    assert_response :success
    assert_not_includes response.body, "data-controller=\"homescreen-modal\""
    assert_not_includes response.body, "Get the App Experience!"
  end

  test "homescreen modal is not shown for unauthenticated users" do
    sign_out

    get new_session_path  # This is where unauthenticated users are redirected

    assert_response :success
    assert_not_includes response.body, "data-controller=\"homescreen-modal\""
    assert_not_includes response.body, "Get the App Experience!"
  end

  private

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password123" }
    follow_redirect!
  end

  def sign_out
    delete session_path
  end
end