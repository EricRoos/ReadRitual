# app/services/book_cover_fetcher.rb
require "httparty"
require "net/http"
require "cgi"

class BookCoverFetcher
  GOOGLE_API = "https://www.googleapis.com/books/v1/volumes?q="

  attr_reader :title, :author, :source_url

  def initialize(title:, author:)
    @title = title
    @author = author
    @source_url = nil
  end

  # Returns a file object (Tempfile) that can be used with ActiveStorage
  def fetch_file
    lookup_cover_url_from_google_books
    return nil unless source_url

    download_to_tempfile
  end

  private

  def lookup_cover_url_from_google_books
    Rails.cache.fetch("book_cover/#{title}/#{author}", expires_in: 12.hours) do
      response = GoogleBooksApi.search_by_title_and_author(title, author)

      return if response.nil?

      image_links = response.dig("items", 0, "volumeInfo", "imageLinks")
      return unless image_links

      @source_url = image_links["large"] || image_links["thumbnail"] || image_links.values.first
    end
  end

  def download_to_tempfile
    response = Net::HTTP.get_response(URI.parse(source_url))
    return nil unless response.is_a?(Net::HTTPSuccess)

    tempfile = Tempfile.new([ "cover", ".jpg" ], binmode: true)
    tempfile.write(response.body)
    tempfile.rewind
    File.open(tempfile)
  rescue => e
    Rails.logger.warn("Cover download failed for '#{title}': #{e.message}")
    nil
  end
end
