class AddDurationMinutesToBook < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :duration_minutes, :integer
  end
end
