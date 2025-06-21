class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  def return_or_redirect_to(path, options = {})
    redirect_to return_to_or_path(path), options
  end

  def return_to_or_path(path)
    params[:return_to] || path
  end
  helper_method :return_to_or_path

  def return_to_title_or(title)
    params[:return_to_title] || title
  end
  helper_method :return_to_title_or
end
