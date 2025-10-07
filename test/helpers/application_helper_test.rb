require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "format_duration_minutes returns nil for blank values" do
    assert_nil format_duration_minutes(nil)
    assert_nil format_duration_minutes("")
    assert_nil format_duration_minutes(0)
  end

  test "format_duration_minutes formats minutes only when under 60" do
    assert_equal "1 minute", format_duration_minutes(1)
    assert_equal "30 minutes", format_duration_minutes(30)
    assert_equal "59 minutes", format_duration_minutes(59)
  end

  test "format_duration_minutes formats exact hours" do
    assert_equal "1 hour", format_duration_minutes(60)
    assert_equal "2 hours", format_duration_minutes(120)
    assert_equal "5 hours", format_duration_minutes(300)
  end

  test "format_duration_minutes formats hours and minutes" do
    assert_equal "1 hour 1 minute", format_duration_minutes(61)
    assert_equal "1 hour 30 minutes", format_duration_minutes(90)
    assert_equal "2 hours 15 minutes", format_duration_minutes(135)
    assert_equal "10 hours 45 minutes", format_duration_minutes(645)
  end

  test "format_duration_minutes handles large durations" do
    assert_equal "24 hours", format_duration_minutes(1440) # 1 day
    assert_equal "25 hours 30 minutes", format_duration_minutes(1530)
    assert_equal "100 hours", format_duration_minutes(6000)
  end

  test "format_duration_minutes uses proper pluralization" do
    # Singular cases
    assert_equal "1 hour", format_duration_minutes(60)
    assert_equal "1 minute", format_duration_minutes(1)
    assert_equal "1 hour 1 minute", format_duration_minutes(61)

    # Plural cases
    assert_equal "2 hours", format_duration_minutes(120)
    assert_equal "2 minutes", format_duration_minutes(2)
    assert_equal "2 hours 2 minutes", format_duration_minutes(122)
  end

  test "format_duration_minutes handles edge cases" do
    # Zero should return nil (blank)
    assert_nil format_duration_minutes(0)

    # Very small duration
    assert_equal "1 minute", format_duration_minutes(1)

    # Just under an hour
    assert_equal "59 minutes", format_duration_minutes(59)

    # Just over an hour
    assert_equal "1 hour 1 minute", format_duration_minutes(61)
  end

  test "random_celebration_message returns string from available messages" do
    # Test that the message is a string and not empty
    message = random_celebration_message
    assert_kind_of String, message
    assert message.length > 0, "Message should not be empty"

    # Test that over many calls, we get different messages (randomness check)
    # This verifies the method is working correctly without duplicating the message data
    messages_seen = Set.new
    100.times do
      messages_seen << random_celebration_message
    end

    # We should see at least 2 different messages in 100 calls (very high probability)
    assert messages_seen.length >= 2, "Expected to see multiple different messages, but got: #{messages_seen.to_a}"

    # Verify all messages are strings
    messages_seen.each do |msg|
      assert_kind_of String, msg
      assert msg.length > 0, "All messages should be non-empty strings"
    end
  end

  test "random_celebration_message returns string" do
    message = random_celebration_message
    assert_kind_of String, message
    assert message.length > 0, "Message should not be empty"
  end

  test "random_goal_achievement_message returns string from available messages" do
    # Test that the message is a string and not empty
    message = random_goal_achievement_message
    assert_kind_of String, message
    assert message.length > 0, "Message should not be empty"

    # Test that over many calls, we get different messages (randomness check)
    messages_seen = Set.new
    100.times do
      messages_seen << random_goal_achievement_message
    end

    # We should see at least 2 different messages in 100 calls (very high probability)
    assert messages_seen.length >= 2, "Expected to see multiple different messages, but got: #{messages_seen.to_a}"

    # Verify all messages are strings
    messages_seen.each do |msg|
      assert_kind_of String, msg
      assert msg.length > 0, "All messages should be non-empty strings"
    end
  end
end
