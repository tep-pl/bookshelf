require 'test_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

class BookshelfTest < ActiveSupport::TestCase

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  test "should not verify/save bookshelf without name" do
    attributes = { password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    assert_not bookshelf.valid?
    assert_not bookshelf.save
  end

  test "should not verify/save bookshelf without password" do
    attributes = { name: "TestName", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    assert_not bookshelf.valid?
    assert_not bookshelf.save
  end

  test "should not verify/save bookshelf without password confirmation" do
    attributes = { name: "TestName", password: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    assert_not bookshelf.valid?
    assert_not bookshelf.save
  end

  test "should not verify/save bookshelf without name and password" do
    bookshelf = Bookshelf.new
    bookshelf.password_confirmation = "TestPassword"
    assert_not bookshelf.valid?
    assert_not bookshelf.save
  end

  test "should not verify/save bookshelf without name and password confirmation" do
    bookshelf = Bookshelf.new
    bookshelf.password = "TestPassword"
    assert_not bookshelf.valid?
    assert_not bookshelf.save
  end

  test "should not verify/save bookshelf without password and password confirmation" do
    bookshelf = Bookshelf.new
    bookshelf.name = "TestName"
    assert_not bookshelf.valid?
    assert_not bookshelf.save
  end

  test "should not verify/save bookshelf without parameters" do
    bookshelf = Bookshelf.new
    assert_not bookshelf.save
  end

  test "should properly verify/save bookshelf with all proper parameters" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    assert bookshelf.save
  end

  test "should not verify/save bookshelf with duplicated name " do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    first_bookshelf = Bookshelf.new(attributes)
    first_bookshelf.save
    second_bookshelf = Bookshelf.new(attributes)
    assert_not second_bookshelf.valid?
    assert_not second_bookshelf.save
  end

  test "should properly verify/save bookshelf with not matching password confirmation " do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPasswordBad" }
    bookshelf = Bookshelf.new(attributes)
    assert_not bookshelf.valid?
    assert_not bookshelf.save
  end

  test "should encrypt password" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    assert_not_same bookshelf.password_hash, "TestPassword"
  end

  test "should authenticate with proper credentials" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.save
    assert_not_nil Bookshelf.authenticate("TestName", "TestPassword")
  end

  test "should have persisted last_login time" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.save
    assert_nil bookshelf.last_login
    bookshelf.persist_login
    assert_not_nil bookshelf.last_login
  end

end