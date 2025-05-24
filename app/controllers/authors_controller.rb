class AuthorsController < ApplicationController
  def index
    @authors = Current.user.authors.includes(books: [ cover_image_attachment: [ :blob ] ]).distinct.order(:name)
  end
end
