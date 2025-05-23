class BookSaver
  def initialize(user, params, book: nil)
    @params = params.to_h.with_indifferent_access
    @user = user
    @book = book
  end

  def build
    authors = @params.delete(:authors) || []
    book = @book || Book.new
    book.assign_attributes(
      @params.merge(user: @user)
    )

    authors = authors.map do |author|
      name = author.with_indifferent_access[:name]
      Author.where("lower(name) = ?", name.downcase).first_or_initialize do |a|
        a.name = name
      end
    end.uniq

    book.authors = authors
    book
  end
end
