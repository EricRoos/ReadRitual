class BookSaver
  def initialize(user, params)
    @params = params.to_h.with_indifferent_access
    @user = user
  end

  def build
    authors = @params.delete(:authors) || []
    book = Book.new(
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
