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

    authors.each do |author|
      name = author.with_indifferent_access[:name]
      author = Author.where("lower(name) = ?", name.downcase).first_or_initialize do |a|
        a.name = name
      end
      book.authors << author unless book.authors.include?(author)
    end

    book
  end
end
