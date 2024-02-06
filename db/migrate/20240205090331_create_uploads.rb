class CreateUploads < ActiveRecord::Migration[7.1]
  def change
    create_table :uploads do |t|
      t.string :file_name
      t.string :content_type
      t.string :file_path

      t.timestamps
    end
  end
end
