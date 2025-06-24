require 'uri'

class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  TRUSTED_HOST = "example.org".freeze

  def return_or_redirect_to(path, options = {})
    redirect_to validated_return_to_or_path(path), options
  end

  def validated_return_to_or_path(path)
    return_to = params[:return_to]
    if return_to.present?
      begin
        uri = URI.parse(return_to)
        # Allow relative URLs or URLs with the trusted host
        if uri.host.nil? || uri.host == TRUSTED_HOST
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
