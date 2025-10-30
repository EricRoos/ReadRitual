require "application_system_test_case"

class ProfileSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)
  end

  test "updating email address" do
    visit profile_path

    # Verify current email is shown
    assert_field "user_email_address", with: @user.email_address

    # Update email address
    new_email = "updated@example.com"
    fill_in "user_email_address", with: new_email
    
    # Find the first Update button (for email form)
    within first(".bg-white", text: "Information") do
      click_button "Update"
    end

    # Verify success message and updated email
    assert_text "Profile updated successfully"
    @user.reload
    assert_equal new_email, @user.email_address
  end

  test "updating yearly reading goal" do
    visit profile_path

    # Verify current goal is shown
    assert_field "user_books_per_year_goal", with: @user.books_per_year_goal.to_s

    # Update goal
    new_goal = 200
    fill_in "user_books_per_year_goal", with: new_goal
    
    # Find the Update Goal button
    within first(".bg-white", text: "Goals") do
      click_button "Update Goal"
    end

    # Verify success message and updated goal
    assert_text "Profile updated successfully"
    @user.reload
    assert_equal new_goal, @user.books_per_year_goal
  end

  test "cannot update goal to invalid value" do
    visit profile_path

    # Try to update goal to 0 (invalid)
    fill_in "user_books_per_year_goal", with: 0
    
    within first(".bg-white", text: "Goals") do
      click_button "Update Goal"
    end

    # Should show error (page doesn't redirect on validation error)
    assert_no_text "Profile updated successfully"
    
    # Goal should not have changed
    @user.reload
    assert_equal 100, @user.books_per_year_goal
  end

  test "cannot update goal to value over 1000" do
    visit profile_path

    # Try to update goal to 1001 (invalid)
    fill_in "user_books_per_year_goal", with: 1001
    
    within first(".bg-white", text: "Goals") do
      click_button "Update Goal"
    end

    # Should show error (page doesn't redirect on validation error)
    assert_no_text "Profile updated successfully"
    
    # Goal should not have changed
    @user.reload
    assert_equal 100, @user.books_per_year_goal
  end

  test "cannot update email to empty value" do
    visit profile_path

    # Try to update email to empty (invalid)
    fill_in "user_email_address", with: ""
    
    within first(".bg-white", text: "Information") do
      click_button "Update"
    end

    # Should show error (page doesn't redirect on validation error)
    assert_no_text "Profile updated successfully"
    
    # Email should not have changed
    @user.reload
    assert_equal "one@example.com", @user.email_address
  end
end
