# frozen_string_literal: true

require "test_helper"

class FontConfigurationTest < ActionDispatch::IntegrationTest
  test "tailwind config file exists and contains apple system fonts" do
    config_path = Rails.root.join("tailwind.config.js")
    assert File.exist?(config_path), "tailwind.config.js should exist"

    config_content = File.read(config_path)
    assert_includes config_content, "-apple-system", "Configuration should include -apple-system font"
    assert_includes config_content, "BlinkMacSystemFont", "Configuration should include BlinkMacSystemFont"
    assert_not_includes config_content, "Inter", "Configuration should not explicitly use Inter font"
  end

  test "tailwind css includes apple system font base styles" do
    css_path = Rails.root.join("app/assets/tailwind/application.css")
    assert File.exist?(css_path), "application.css should exist"

    css_content = File.read(css_path)
    assert_includes css_content, "-apple-system", "CSS should include Apple system font"
    assert_includes css_content, "@layer base", "CSS should use Tailwind's base layer"
  end
end
