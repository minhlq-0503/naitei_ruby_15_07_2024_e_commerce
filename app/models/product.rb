class Product < ApplicationRecord
  belongs_to :category
  has_many :carts, dependent: :destroy
  has_many :order_items, dependent: :nullify
  has_many :feedbacks, dependent: :destroy
  has_one_attached :image

  validates :category_id, presence: true
  validates :product_name, presence: true
  validates :price, presence: true,
    numericality: {greater_than_or_equal_to: Settings.value.min_numeric}
  validates :stock, presence: true,
    numericality: {greater_than_or_equal_to: Settings.value.min_numeric}
  validates :sold, presence: true,
    numericality: {greater_than_or_equal_to: Settings.value.min_numeric}
  validates :rating,
            numericality: {greater_than_or_equal_to: Settings.value.min_numeric,
                           less_than_or_equal_to: Settings.value.rate_max},
            allow_nil: true

  delegate :category_name, to: :category, prefix: true

  scope(:featured, lambda do
    select(
      "products.*,
          (#{Settings.featured.rating_weight} * COALESCE(products.rating, 0) +
            #{Settings.featured.sold_weight} * COALESCE(products.sold, 0) +
            #{Settings.featured.feedback_weight} * COALESCE(
            COUNT(feedbacks.id), 0)) AS score,
          COUNT(feedbacks.id) AS feedback_count"
    )
      .joins("LEFT JOIN feedbacks ON feedbacks.product_id = products.id")
      .group("products.id")
      .having("products.rating >= #{Settings.featured.min_rating}")
      .order("score DESC")
      .limit(Settings.featured.limit)
  end)
  scope(:by_category_ids, lambda do |category_ids|
    where(category_id: category_ids) if category_ids.present?
  end)
end
