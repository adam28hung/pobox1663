class AddDbIndex < ActiveRecord::Migration
  def change
    add_index :users, :device_token
    add_index :posts, :lat
    add_index :posts, :lng
  end
end
