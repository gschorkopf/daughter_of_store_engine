class Product < ActiveRecord::Base
  attr_accessible :title, :description, :price, :status, :category_ids, :store_id
  has_and_belongs_to_many :categories

  validates :title, presence: :true,
                    uniqueness: { case_sensitive: false }
  validates :description, presence: :true
  validates :status, presence: :true,
                     inclusion: { in: %w(active retired) }
  validates :price, presence: :true,
                    format: { with: /^\d+??(?:\.\d{0,2})?$/ },
                    numericality: { greater_than: 0 }
  # validates :uniqueness, :scope => :store_id

  def self.by_category(category_id)
    if category_id.present?
      Category.find(category_id).products
    else
      scoped
    end
  end

  def toggle_status
    if status == 'active'
      update_attributes(status: 'retired')
    elsif status == 'retired'
      update_attributes(status: 'active')
    end
  end
end
