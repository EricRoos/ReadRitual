class Author < ApplicationRecord
  has_and_belongs_to_many :books

  # replaces this authors books with the given author_ids
  # and destroys this author
  def split_into(author_ids)
    authors = Author.where(id: author_ids).index_by(&:id)
    Author.transaction do
      books.each do |book|
        author_ids.each do |author_id|
          author = authors[author_id]
          next unless author
          book.authors << author unless book.authors.include?(author)
        end
        book.save!
      end
      destroy
    end
  end
end
