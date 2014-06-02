require 'test_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

class BooksControllerTest < ActionController::TestCase

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  test "should get index" do
    session[:admin] = true
    get :index
    assert_response :success
    assert_not_nil assigns(:book)
    assert_not_nil assigns(:fresh_book)
  end

  test "should get redirected when asking for index without authentication" do
    get :index

    assert_redirected_to "/"
    assert flash[:error].include?("Sign in, please")
  end

  test "should create new book" do
    attributes = {
        author: "TestAuthor",
        title: "TestTitle",
        cover: Rack::Test::UploadedFile.new(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }

    assert_difference('Book.count', 1) do
      post :create, book: attributes
    end
    assert_redirected_to "/books"
  end

  test "should not create new book without author" do
    attributes = {
        title: "TestTitle",
        cover: Rack::Test::UploadedFile.new(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }

    assert_difference('Book.count', 0) do
      post :create, book: attributes
    end
    assert_redirected_to "/books?new_book_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create new book without title" do
    attributes = {
        author: "TestAuthor",
        cover: Rack::Test::UploadedFile.new(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }

    assert_difference('Book.count', 0) do
      post :create, book: attributes
    end
    assert_redirected_to "/books?new_book_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create new book without cover" do
    attributes = {
        author: "TestAuthor",
        title: "TestTitle"
    }

    assert_difference('Book.count', 0) do
      post :create, book: attributes
    end
    assert_redirected_to "/books?new_book_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create new book without title and cover" do
    assert_difference('Book.count', 0) do
      post :create, book: { author: "TestAuthor" }
    end
    assert_redirected_to "/books?new_book_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create new book without author and cover" do
    assert_difference('Book.count', 0) do
      post :create, book: { title: "TestTitle" }
    end
    assert_redirected_to "/books?new_book_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create new book without author and title" do
    assert_difference('Book.count', 0) do
      post :create, book:{ cover: Rack::Test::UploadedFile.new(File.join(Rails.root, '/test/fixtures/files/cover.gif')) }
    end
    assert_redirected_to "/books?new_book_err=true"
    assert_not flash[:error].empty?
  end

  test "should properly delete book" do
    attributes = {
        author: "TestAuthor",
        title: "TestTitle",
        cover: Rack::Test::UploadedFile.new(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    book = Book.new(attributes)
    book.save

    assert_difference('Book.count', -1) do
      delete :destroy, id: book.id
    end
    assert_redirected_to "/books"
  end

end