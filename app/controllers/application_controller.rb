require "uri"

class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern


  def native_app?
    Rails.logger.info "User-Agent: #{request.user_agent}"
    request.user_agent&.include?("Turbo Native")
  end
  helper_method :native_app?

  def show_top_nav?
    !native_app?
  end
  helper_method :show_top_nav?

  def show_bottom_nav?
    false && native_app?
  end
  helper_method :show_bottom_nav?

  def return_or_redirect_to(path, options = {})
    redirect_to return_to_or_path(path), options
  end

  def return_to_or_path(path)
    return_to = params[:return_to]
    if return_to.present?
      begin
        uri = URI.parse(return_to)
        # Allow relative URLs or URLs with the trusted host
        if uri.host.nil?
          return uri.to_s
        end
      rescue URI::InvalidURIError
        # Handle invalid URI
      end
    end
    path # Fallback to the provided path
  end
  helper_method :return_to_or_path

  def return_to_title_or(title)
    params[:return_to_title] || title
  end
  helper_method :return_to_title_or
end
