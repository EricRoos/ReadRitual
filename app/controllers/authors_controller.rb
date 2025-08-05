class AuthorsController < ApplicationController
  # Displays authors grouped by their collaboration patterns.
  # Solo authors appear individually, while authors who have collaborated
  # on books together are grouped as a single entry.
  def index
    book_ids = Current.user.books.pluck(:id)
    grouped_data = Authoring.grouped(book_ids)

    # Convert to array format for the view and sort by first author's name
    @author_groups = grouped_data.map do |authors, books|
      {
        authors: authors,
        books: books
      }
    end.sort_by { |group| group[:authors].first&.name || "" }
  end
end
