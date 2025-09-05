class AddBooksPerYearGoalToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :books_per_year_goal, :integer, default: 100, null: false
  end
end
