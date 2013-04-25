class AddAttachmentPhotoToImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.attachment :photo
      t.references :product

      t.timestamps
    end
  end
end
