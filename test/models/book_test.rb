require 'test_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

class BookTest < ActiveSupport::TestCase

  test "should not verify/save book without author" do
    attributes = {
        title: "TestTitle",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    book = Book.new(attributes)
    assert_not book.valid?
    assert_not book.save
  end

  test "should not verify/save book without title" do
    attributes = {
        author: "TestAuthor",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    book = Book.new(attributes)
    assert_not book.valid?
    assert_not book.save
  end

  test "should not verify/save book without cover" do
    attributes = {
        author: "TestAuthor",
        title: "TestTitle"
    }
    book = Book.new(attributes)
    assert_not book.valid?
    assert_not book.save
  end

  test "should not verify/save book without author and title" do
    book = Book.new
    book.cover = File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    assert_not book.valid?
    assert_not book.save
  end

  test "should not verify/save book without author and cover" do
    book = Book.new
    book.title = "TestTitle"
    assert_not book.valid?
    assert_not book.save
  end

  test "should not verify/save book without title and cover" do
    book = Book.new
    book.author = "TestAuthor"
    assert_not book.valid?
    assert_not book.save
  end

  test "should not verify/save book without parameters" do
    book = Book.new
    assert_not book.valid?
    assert_not book.save
  end

  test "should properly verify/save book with all proper parameters" do
    attributes = {
        author: "TestAuthor",
        title: "TestTitle",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    book = Book.new(attributes)
    assert book.valid?
    assert book.save
  end

  test "should not verify/save book with duplicated title" do
    attributes = {
        author: "TestAuthor",
        title: "TestTitle",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    first_book = Book.new(attributes)
    first_book.save
    second_book = Book.new(attributes)
    assert_not second_book.valid?
    assert_not second_book.save
  end

end