class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

  # GET /books or /books.json
  def index
    books_query = Current.user.books.includes(:authors).order(start_date: :desc).with_attached_cover_image

    # Filter by author IDs if provided - book must have ALL specified authors
    if params[:author_ids].present?
      author_ids = Array(params[:author_ids]).map(&:to_i)

      # Find books that are authored by ALL specified authors
      books_query = books_query.joins(:authors_books)
                              .where(authors_books: { author_id: author_ids })
                              .group("books.id")
                              .having("COUNT(DISTINCT authors_books.author_id) = ?", author_ids.length)
    end

    @books = books_query
  end

  # GET /books/1 or /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
    @book.authors.build
    @book.start_date = Time.zone.now.to_date
  end

  # GET /books/1/edit
  def edit
    @book.authors.build if @book.authors.empty?
    @book.start_date ||= Time.zone.now.to_date
  end

  # POST /books or /books.json
  def create
    create_params = if params[:audible_url].present?
      begin
        AudibleBookDetailsFetcher.new.fetch_book_details(params[:audible_url])
      rescue ArgumentError => e
        flash.now[:alert] = e.message
        nil
      rescue StandardError => e
        Rails.logger.error "Error fetching book details from Audible: #{e.message}"
        flash.now[:alert] = "There was an error fetching the book details from Audible. Please check the URL and try again."
        nil
      end
    else
      book_params
    end

    @book = BookSaver.new(Current.user, create_params).build if create_params.present?

    respond_to do |format|
      if @book&.save
        if native_app?
          format.html { refresh_or_redirect_to @book, notice: "Book was successfully created." }
        else
          format.html { return_or_redirect_to(@book, notice: "Book was successfully created.") }
        end
        format.json { render :show, status: :created, location: @book }
      else
        @book.authors.build if @book && @book.authors.empty?
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1 or /books/1.json
  def update
    was_in_progress = @book.finish_date.nil?
    @book = BookSaver.new(Current.user, book_params, book: @book).build
    respond_to do |format|
      if @book.save
        # Check if book was just completed from dashboard
        if was_in_progress && @book.finish_date.present? && came_from_dashboard?
          format.turbo_stream { render :celebrate_completion }
          format.html { return_or_redirect_to(root_path, notice: "Congratulations! You've completed another book!") }
        else
          if native_app?
            format.html { refresh_or_redirect_to @book, notice: "Book was successfully updated." }
          else
            format.html { return_or_redirect_to(@book, notice: "Book was successfully updated.") }
          end
        end
        format.json { render :show, status: :ok, location: @book }
      else
        @book.authors.build if @book.authors.empty?
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1 or /books/1.json
  def destroy
    @book.destroy!

    respond_to do |format|
      if native_app?
        format.html { refresh_or_redirect_to books_path, notice: "Book was successfully created." }
      else
        format.html { return_or_redirect_to(books_path, notice: "Book was successfully created.") }
      end
      format.json { head :no_content }
    end
  end

  protected

  def manual_entry?
    params[:manual].present?
  end
  helper_method :manual_entry?

  def came_from_dashboard?
    params[:return_to] == root_path
  end

  private

  def show_top_nav?
    super
  end

  def show_bottom_nav?
    super && action_name == "index"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_book
    @book = Current.user.books.includes(:authors).find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def book_params
    params.require(:book).permit(:cover_url, :cover_image, :start_date, :finish_date, :title, authors: [ :name ])
  end
end
