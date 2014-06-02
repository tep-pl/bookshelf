class Bookshelf < ActiveRecord::Base
  has_many :connections
  has_many :books, through: :connections
  attr_accessor :password

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :password
  validates_presence_of :password_confirmation
  validates_confirmation_of :password

  before_create :encrypt_password
  before_update :encrypt_password

  def self.authenticate(name, password)
    bookshelf = find_by_name(name)
    if bookshelf && bookshelf.password_hash == BCrypt::Engine.hash_secret(password, bookshelf.password_salt)
      bookshelf
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def persist_login
    self.update_columns(last_login: Time.now)
  end

end