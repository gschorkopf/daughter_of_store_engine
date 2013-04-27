class CollectionProduct < ActiveRecord::Base
  attr_accessible :product_id, :collection_id

  belongs_to :product
  belongs_to :collection
end
