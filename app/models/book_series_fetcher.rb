# app/services/book_cover_fetcher.rb
require "httparty"
require "open-uri"
require "cgi"

class BookSeriesFetcher
  GOOGLE_API = "https://www.googleapis.com/books/v1/volumes?q="

  attr_reader :title, :author, :source_url

  def initialize(title:, author:)
    @title = title
    @author = author
    @source_url = nil
  end

  # Returns a file object (Tempfile) that can be used with ActiveStorage
  def fetch_series
    lookup_series_from_google_books
  end

  private

  def lookup_series_from_google_books
    Rails.cache.fetch("book_series/#{title}/#{author}", expires_in: 12.hours) do
      response = GoogleBooksApi.search_by_title_and_author(title, author)

      return unless response.success?

      response.dig("items", 0, "volumeInfo", "publisher")
    end
  end
end
