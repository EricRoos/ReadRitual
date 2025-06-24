class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

  # GET /books or /books.json
  def index
    @books = Current.user.books.includes(:authors).order(start_date: :desc).with_attached_cover_image
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
      rescue
        flash.now[:alert] = "There was an error fetching the book details from Audible. Please check the URL and try again."
        nil
      end
    else
      book_params
    end

    @book = BookSaver.new(Current.user, create_params).build if create_params.present?

    respond_to do |format|
      if @book&.save
        format.html { return_or_redirect_to(@book, notice: "Book was successfully created.") }
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
    @book = BookSaver.new(Current.user, book_params, book: @book).build
    respond_to do |format|
      if @book.save
        format.html { return_or_redirect_to @book, notice: "Book was successfully updated." }
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
      format.html { redirect_to books_path, status: :see_other, notice: "Book was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  protected

  def manual_entry?
    params[:manual].present?
  end
  helper_method :manual_entry?

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Current.user.books.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:cover_url, :cover_image, :start_date, :finish_date, :title, authors: [ :name ])
    end
end
