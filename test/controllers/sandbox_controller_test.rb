require "test_helper"

class SandboxControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    login_as(@user)
  end

  test "should get index" do
    get root_path
    assert_response :success
  end

  test "dashboard shows user statistics" do
    get root_path
    assert_response :success
    assert_select "h1", text: "Your reading dashboard"
  end

  test "estimated completion is hidden when feature flag is disabled" do
    Flipper.disable(:show_estimated_completion)

    get root_path
    assert_response :success

    # Should not contain the estimated completion section
    assert_select "span", text: "Est. completion:", count: 0
    # Grid should have 2 columns instead of 3
    assert_select ".grid-cols-1.md\\:grid-cols-2"
  end

  test "estimated completion is shown when feature flag is enabled" do
    Flipper.enable(:show_estimated_completion)

    get root_path
    assert_response :success

    # Should contain the estimated completion section
    assert_select "span", text: "Est. completion:"
    # Grid should have 3 columns
    assert_select ".grid-cols-1.md\\:grid-cols-3"
  end

  test "estimated completion can be enabled for specific user" do
    other_user = users(:two)

    # Enable for specific user only
    Flipper.disable(:show_estimated_completion)
    Flipper.enable_actor(:show_estimated_completion, @user)

    # Current user should see the feature
    get root_path
    assert_response :success
    assert_select "span", text: "Est. completion:"

    # Other user should not see the feature
    login_as(other_user)
    get root_path
    assert_response :success
    assert_select "span", text: "Est. completion:", count: 0
  end

  teardown do
    # Clean up feature flags after each test
    Flipper.disable(:show_estimated_completion)
  end
end
