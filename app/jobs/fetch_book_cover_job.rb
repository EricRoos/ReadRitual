class FetchBookCoverJob < ApplicationJob
  queue_as :default

  def perform(book)
    book.fetch_cover_image
  end
end
