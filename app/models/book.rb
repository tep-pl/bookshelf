class Book < ActiveRecord::Base
  has_many :connections
  has_many :bookshelves, through: :connections
  mount_uploader :cover, CoverUploader

  validates_presence_of :author
  validates_presence_of :title
  validates_uniqueness_of :title
  validates_presence_of :cover

end