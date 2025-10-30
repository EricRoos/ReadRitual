require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    login_as(@user)
  end

  test "should get show" do
    get profile_url
    assert_response :success
  end

  test "should update email address" do
    new_email = "newemail@example.com"
    patch profile_url, params: { user: { email_address: new_email } }
    assert_redirected_to profile_url
    assert_equal new_email, @user.reload.email_address
  end

  test "should update books per year goal" do
    new_goal = 200
    patch profile_url, params: { user: { books_per_year_goal: new_goal } }
    assert_redirected_to profile_url
    assert_equal new_goal, @user.reload.books_per_year_goal
  end

  test "should update both email and goal" do
    new_email = "updated@example.com"
    new_goal = 150
    patch profile_url, params: { user: { email_address: new_email, books_per_year_goal: new_goal } }
    assert_redirected_to profile_url
    @user.reload
    assert_equal new_email, @user.email_address
    assert_equal new_goal, @user.books_per_year_goal
  end

  test "should not update with invalid email" do
    patch profile_url, params: { user: { email_address: "" } }
    assert_response :unprocessable_entity
  end

  test "should not update with invalid goal" do
    patch profile_url, params: { user: { books_per_year_goal: 0 } }
    assert_response :unprocessable_entity
  end

  test "should not update with goal greater than 1000" do
    patch profile_url, params: { user: { books_per_year_goal: 1001 } }
    assert_response :unprocessable_entity
  end
end
