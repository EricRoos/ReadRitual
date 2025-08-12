require "net/http"
require "nokogiri"

class AudibleBookDetailsFetcher
  def fetch_book_details(audible_shared_url)
    unless valid_audible_url?(audible_shared_url)
      raise ArgumentError, "Invalid URL: URL must belong to Audible's domain."
    end

    if Rails.env.production?
      Sentry.logger.trace(
        "AudibleBookDetailsFetcher#fetch_book_details",
        audible_shared_url:
      )
    end

    uri = URI.parse(audible_shared_url)
    max_redirects = 5
    redirects = 0
    response = nil

    loop do
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      if response.is_a?(Net::HTTPRedirection)
        location = response["location"]
        uri = URI.parse(location)
        # If location is a relative path, build absolute URL
        unless uri.host
          uri = URI.join("#{http.use_ssl? ? 'https' : 'http'}://#{http.address}", location)
        end
        redirects += 1
        raise "Too many redirects" if redirects > max_redirects
      else
        break
      end
    end

    html_content = response.body
    doc = Nokogiri::HTML(html_content)
    Rails.logger.info "#{doc}"
    metadata = JSON.parse(doc.at_css("adbl-product-metadata script").text)
    product_details = JSON.parse(doc.at_css("adbl-product-details.product-details-widget-spacing script").text)

    series_name = nil
    series_name = product_details["series"][0]["name"] if product_details["series"]&.any?
    duration_minutes = begin
      hours, minutes = product_details["duration"].match(/(\d+) hrs and (\d+) mins/)[1..2].map(&:to_i)
      hours * 60 + minutes
    rescue => e
      Rails.logger.error "Error parsing duration: #{e.message}"
      nil
    end

    book_details = {
      title: doc.at_css("adbl-title-lockup h1").text.strip,
      series_name:,
      cover_url: doc.at_css("adbl-product-image img")["src"],
      authors: metadata["authors"].map { |author| { name: author["name"] } },
      duration_minutes:
    }
  end

  private

  def valid_audible_url?(url)
    allowed_hosts = [ "www.audible.com", "audible.com" ]
    uri = URI.parse(url)
    allowed_hosts.include?(uri.host)
  rescue URI::InvalidURIError
    false
  end
end
