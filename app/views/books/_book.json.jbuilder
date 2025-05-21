json.extract! book, :id, :start_date, :finish_date, :title, :user_id, :created_at, :updated_at
json.url book_url(book, format: :json)
