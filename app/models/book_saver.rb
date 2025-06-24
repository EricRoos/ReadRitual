class BookSaver
  def initialize(user, params, book: nil)
    @params = params.to_h.with_indifferent_access
    @user = user
    @book = book
  end

  def build
    authors = @params.delete(:authors) || []
    cover_url = @params.delete(:cover_url)
    skip_auto_cover = @params.delete(:skip_auto_cover)

    book = @book || Book.new
    book.skip_auto_cover = skip_auto_cover
    book.assign_attributes(
      @params.merge(user: @user)
    )

    book.start_date ||= Date.current

    authors.each do |author|
      name = author.with_indifferent_access[:name].strip
      author = Author.where("lower(name) = ?", name.downcase).first_or_initialize do |a|
        a.name = name
      end
      book.authors << author unless book.authors.include?(author)
    end

    if cover_url.present?
      book.cover_from_url(cover_url)
    end

    book
  end
end
