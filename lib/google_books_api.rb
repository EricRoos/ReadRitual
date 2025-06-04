require "httparty"
require "open-uri"
require "cgi"

module GoogleBooksApi
  GOOGLE_API = "https://www.googleapis.com/books/v1/volumes?q="
  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new(size: 64.megabytes)
  end

  def self.search_by_title_and_author(title, author)
    cache.fetch([ title, author ].join("_")) do
      query = CGI.escape("intitle:\"#{title}\" inauthor:\"#{author}\"")
      response = HTTParty.get("#{GOOGLE_API}#{query}")
      if response.body.nil? || response.body.empty?
        return nil
      end
      JSON.parse(response.body)
    end
  end
end
