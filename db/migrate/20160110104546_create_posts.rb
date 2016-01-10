class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :message
      t.string :site_name
      t.float :lat
      t.float :lng
      t.string :address
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
