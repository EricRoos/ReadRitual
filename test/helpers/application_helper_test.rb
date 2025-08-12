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
end
