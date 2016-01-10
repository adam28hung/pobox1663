class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :token
      t.string :nickname
      t.string :os
      t.string :version

      t.timestamps null: false
    end
  end
end
