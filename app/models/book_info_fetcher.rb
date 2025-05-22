class BookInfoFetcher
  def initialize(client: OpenAI::Client.new(access_token: ENV["READ_RITUAL_OPEN_AI_KEY"].strip))
    puts "\"#{ENV["READ_RITUAL_OPEN_AI_KEY"]}\""
    @client = client
  end

  def fetch_with_image(title:, author:)
    book_info = fetch_book_info(title:, author:)

    image_data = download_image(book_info[:cover_image_url])
    book_info[:cover_image_bytes] = image_data

    book_info
  end

  private

  def fetch_book_info(title:, author:)
    response = @client.responses.create(parameters: {
      model: "gpt-4o",
      input: prompt(title, author)
    })

    puts response

    content = response.dig("choices", 0, "message", "content")
    JSON.parse(content, symbolize_names: true)
  end

  def download_image(url)
    URI.open(url, "rb", &:read) # Returns the binary bytes
  rescue => e
    warn "Failed to download image: #{e.message}"
    nil
  end

  def prompt(title, author)
    <<~PROMPT
      I have a book with the following details:
      Title: "#{title}"
      Author: "#{author}"

      Please search for this book and return the following information in JSON format:
      - "title": the full title of the book
      - "author_names": an array of all authors
      - "isbn": the primary ISBN (either physical or digital)
      - "audio_length": the audiobook runtime as an integer
      - "audio_length_units": the time unit used for runtime (e.g., minutes)
      - "media_type": must be "audiobook"
      - "cover_image_url": a direct URL to the book's cover image
    PROMPT
  end
end
