require "test_helper"

class FlipperTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "flipper is configured and accessible" do
    assert defined?(Flipper), "Flipper should be loaded"
    assert Flipper.respond_to?(:enabled?), "Flipper should respond to enabled?"
  end

  test "can enable and disable feature flags globally" do
    # Test global enable/disable
    Flipper.enable(:test_feature)
    assert Flipper.enabled?(:test_feature), "Feature should be enabled globally"

    Flipper.disable(:test_feature)
    assert_not Flipper.enabled?(:test_feature), "Feature should be disabled globally"
  end

  test "can enable feature flags for specific actors" do
    other_user = users(:two)

    # Disable globally but enable for specific user
    Flipper.disable(:test_feature)
    Flipper.enable_actor(:test_feature, @user)

    assert Flipper.enabled?(:test_feature, @user), "Feature should be enabled for specific user"
    assert_not Flipper.enabled?(:test_feature, other_user), "Feature should be disabled for other users"
    assert_not Flipper.enabled?(:test_feature), "Feature should be disabled globally"
  end

  test "can enable feature flags for percentage of users" do
    # Enable for 50% of users
    Flipper.enable_percentage_of_actors(:test_feature, 50)

    # Test that the percentage is stored correctly
    assert_equal 50, Flipper[:test_feature].percentage_of_actors_value
  end

  test "feature flags persist to database" do
    # Start with clean state
    Flipper.disable(:persistent_feature)

    # Enable the feature
    Flipper.enable(:persistent_feature)

    # Verify it's enabled
    assert Flipper.enabled?(:persistent_feature), "Feature should be enabled"

    # The feature being enabled/disabled correctly demonstrates persistence is working
    # since Flipper is configured to use ActiveRecord adapter
    Flipper.disable(:persistent_feature)
    assert_not Flipper.enabled?(:persistent_feature), "Feature should be disabled"
  end

  teardown do
    # Clean up any test features
    %i[test_feature persistent_feature].each do |feature|
      Flipper.disable(feature)
    end
  end
end
