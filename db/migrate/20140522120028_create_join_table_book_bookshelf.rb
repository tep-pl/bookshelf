class CreateJoinTableBookBookshelf < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.references :bookshelf
      t.references :book
      t.timestamps
    end
  end
end
