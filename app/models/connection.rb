class Connection < ActiveRecord::Base
  belongs_to :bookshelf
  belongs_to :book
end