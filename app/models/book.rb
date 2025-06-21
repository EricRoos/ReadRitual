class Book < ApplicationRecord
  belongs_to :user, touch: true
  scope :in_progress, -> { where(finish_date: nil) }
  scope :completed, -> { where.not(finish_date: nil) }
  scope :recently_completed, -> { completed.where("finish_date >= ?", 1.month.ago).order(finish_date: :desc) }

  validates :title, presence: true
  validates :start_date, presence: true
  validate :start_date_before_today
  validates :finish_date, allow_nil: true, comparison: { greater_than_or_equal_to: :start_date }

  validate :ensure_authors_exist

  has_and_belongs_to_many :authors

  has_one_attached :cover_image
  has_one :cover_image_attachments

  after_commit :fetch_cover_image_later, on: :create, unless: :cover_image_attached?

  broadcasts_refreshes

  def cover_image_attached?
    cover_image.attached?
  end

  def start_date_before_today
    return if start_date <= Time.zone.now.to_date
    errors.add(:start_date, "must be in the past or today")
  end

  def presentation_string
    if finish_date
      "#{title} (#{start_date.strftime("%Y-%m-%d")} - #{finish_date.strftime("%Y-%m-%d")})"
    else
      "#{title} (#{start_date.strftime("%Y-%m-%d")} - in progress)"
    end
  end

  def authors_names
    @authors_names ||= authors.map(&:name).join(", ")
  end

  def ensure_authors_exist
    if authors.empty?
      errors.add(:book, "must have at least one author")
    end
  end

  def cover_image_url
    if cover_image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(cover_image, only_path: true)
    else
      "missing_book_cover_v2.png"
    end
  end

  def fetch_series
    self.series_name = BookSeriesFetcher.new(title:, author: authors.first.name).fetch_series
  end

  def fetch_cover_image_later
    FetchBookCoverJob.set(wait_until: 1.second.from_now).perform_later(self)
  end

  def fetch_cover_image
    if cover_image.attached?
      nil
    else
      tmpfile = BookCoverFetcher.new(title:, author: authors.first.name).fetch_file
      if tmpfile
        cover_image.attach(io: File.open(tmpfile), filename: "#{title}.jpg", content_type: "image/jpeg")
        tmpfile.close
      end
      nil
    end
  end

  def cover_from_url(cover_url)
    return if cover_image.attached?

    begin
      file = URI.open(cover_url)
      cover_image.attach(io: file, filename: "#{title}.jpg", content_type: "image/jpeg")
    rescue OpenURI::HTTPError => e
      Rails.logger.error("Failed to fetch cover image from URL: #{e.message}")
    rescue StandardError => e
      Rails.logger.error("An error occurred while fetching cover image: #{e.message}")
    end
  end
end
