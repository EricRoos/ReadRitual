class Book < ApplicationRecord
  belongs_to :user
  scope :in_progress, -> { where(finish_date: nil) }
  scope :completed, -> { where.not(finish_date: nil) }
  scope :recently_completed, -> { completed.where("finish_date >= ?", 1.month.ago) }

  validates :title, presence: true
  validates :start_date, presence: true
  validates :start_date, comparison: { less_than_or_equal_to: Date.today }
  validates :finish_date, allow_nil: true, comparison: { greater_than_or_equal_to: :start_date }

  validate :ensure_authors_exist

  has_and_belongs_to_many :authors

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
end
