require 'test_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

class ConnectionTest < ActiveSupport::TestCase

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  test "should contain proper references" do
    first_book_attributes = {
        author: "FirstBookTestAuthor",
        title: "FirstBookTestTitle",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    first_book = Book.new(first_book_attributes)

    second_book_attributes = {
        author: "SecondBookTestAuthor",
        title: "SecondBookTestTitle",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    second_book = Book.new(second_book_attributes)

    bookshelf_attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(bookshelf_attributes)

    bookshelf.books << first_book
    bookshelf.books << second_book
    bookshelf.save

    assert bookshelf.books.length == 2
    assert first_book.bookshelves.include?(bookshelf)
    assert second_book.bookshelves.include?(bookshelf)
  end

end