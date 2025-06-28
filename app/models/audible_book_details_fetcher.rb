require "net/http"
require "nokogiri"

class AudibleBookDetailsFetcher
  # audible_shared_url: a url that contains the Audible book details in HTML format
  def fetch_book_details(audible_shared_url)
    # Validate the URL to ensure it belongs to a trusted domain
    unless valid_audible_url?(audible_shared_url)
      raise ArgumentError, "Invalid URL: URL must belong to Audible's domain."
    end

    # Fetch the URL and read the HTML content
    html_content = Net::HTTP.get(URI.parse(audible_shared_url))

    # Parse the HTML content using Nokogiri
    doc = Nokogiri::HTML(html_content)

    Rails.logger.info "#{doc}"
    metadata = JSON.parse(doc.at_css("adbl-product-metadata script").text)
    product_details = JSON.parse(doc.at_css("adbl-product-details.product-details-widget-spacing script").text)

    series_name = nil
    series_name = product_details["series"][0]["name"] if product_details["series"]&.any?

    # Extract book details
    book_details = {
      title: doc.at_css("adbl-title-lockup h1").text.strip,
      series_name:,
      cover_url: doc.at_css("adbl-product-image img")["src"],
      authors: metadata["authors"].map { |author| { name: author["name"] } }
    }
  end

  private

  # Validate that the URL belongs to Audible's domain
  def valid_audible_url?(url)
    allowed_hosts = [ "www.audible.com", "audible.com" ]
    uri = URI.parse(url)
    allowed_hosts.include?(uri.host)
  rescue URI::InvalidURIError
    false
  end
end
