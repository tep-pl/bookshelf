class CreateBookshelves < ActiveRecord::Migration
  def change
    create_table :bookshelves do |t|
      t.string :name
      t.string :password_hash
      t.string :password_salt
      t.datetime :last_login
      t.datetime :pos_changes
      t.timestamps
    end
  end
end
