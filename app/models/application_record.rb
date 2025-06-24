class ApplicationRecord < ActiveRecord::Base
  CACHE_VERSION = 2
  primary_abstract_class

  def cache_key
    "#{super}-v#{CACHE_VERSION}"
  end
end
