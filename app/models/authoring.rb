class Authoring
  attr_accessor :book, :authors

  def initialize(book:, authors:)
    @book = book
    @authors = authors
  end

  #
  # Returns a helpful structure that groups sets of authors
  # with their associated books.
  #
  def self.grouped(book_ids)
    return {} if book_ids.empty?

    authorings = all(book_ids)
    return {} if authorings.empty?

    # Group by authors array as key, with unique books as values
    authorings.group_by(&:authors).transform_values do |author_authorings|
      author_authorings.map(&:book).uniq
    end
  end

  #
  # Returns authors grouped by their collaboration patterns
  # with book counts instead of full book objects (for lazy loading)
  #
  def self.grouped_without_books(book_ids)
    return {} if book_ids.empty?

    authorings = all(book_ids)
    return {} if authorings.empty?

    # Group by authors array as key, with book count as values
    authorings.group_by(&:authors).transform_values do |author_authorings|
      author_authorings.map(&:book).uniq.count
    end
  end

  def self.all(book_ids = [])
    return [] if book_ids.empty?

    # Using Arel to build a query that aggregates authors for each book
    # This assumes a many-to-many relationship between books and authors
    # through an authors_books join table.
    ab = Arel::Table.new(:authors_books)
    query = ab
      .project(
        ab[:book_id],
        Arel::Nodes::NamedFunction.new("array_agg", [ ab[:author_id] ])
      )
      .group(ab[:book_id])

    # Scope by book_ids if provided
    query = query.where(ab[:book_id].in(book_ids))

    collected_book_ids = []
    collected_author_ids = []

    result = ActiveRecord::Base.connection.exec_query(query.to_sql).rows.map do |row|
      # Use PG::TextDecoder::Array to robustly decode the PostgreSQL array string
      decoder = PG::TextDecoder::Array.new(name: "int4")
      value = decoder.decode(row[1]).map(&:to_i)

      collected_book_ids << row[0]
      value.each do |author_id|
        collected_author_ids << author_id
      end

      [ row[0], value ]
    end

    books = Book.includes(:user).where(id: collected_book_ids).index_by(&:id)
    authors = Author.where(id: collected_author_ids).index_by(&:id)

    result.map do |row|
      new(book: books[row[0]], authors: row[1].map { |id| authors[id] })
    end
  end
end
