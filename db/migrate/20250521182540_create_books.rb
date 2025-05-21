class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.date :start_date
      t.date :finish_date
      t.string :title
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
