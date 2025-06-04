class FetchBookCoverJob < ApplicationJob
  queue_as :default

  def perform(book)
    book.fetch_cover_image
    book.fetch_series
    book.save
  end
end
