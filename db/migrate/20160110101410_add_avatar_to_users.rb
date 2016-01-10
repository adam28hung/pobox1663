class AddAvatarToUsers < ActiveRecord::Migration
  def up
    add_attachment :users, :avatar
    add_column :users, :avatar_fingerprint, :string
  end

  def down
    remove_column :users, :avatar_fingerprint
    remove_attachment :users, :avatar
  end
end
