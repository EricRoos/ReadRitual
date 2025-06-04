require "httparty"
require "open-uri"
require "cgi"

module GoogleBooksApi
  GOOGLE_API = "https://www.googleapis.com/books/v1/volumes?q="
  def self.search_by_title_and_author(title, author)
    query = CGI.escape("intitle:\"#{title}\" inauthor:\"#{author}\"")
    HTTParty.get("#{GOOGLE_API}#{query}")
  end
end
