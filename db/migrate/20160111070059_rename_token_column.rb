class RenameTokenColumn < ActiveRecord::Migration
  def change
    rename_column :users, :token, :device_token
  end
end
