require 'test_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

class BooksFlowTest < ActionDispatch::IntegrationTest

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  test "admin adds new book to the library, user creates his bookshelf and adds the book to it" do

    # log in as admin, add new book and log out
    get "/"
    post_via_redirect "/sessions", name: "admin", password: "admin"
    test_book = {
        author: "TestAuthor",
        title: "TestTitle",
        cover: Rack::Test::UploadedFile.new(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    assert_difference('Book.count', 1) do
      post_via_redirect "/books", book: test_book
    end
    assert_response :success
    delete_via_redirect "/log_out"
    assert_response :success

    # create new bookshelf and log in to it
    test_bookshelf = {
        name: "TestName",
        password: "TestPassword",
        password_confirmation: "TestPassword"
    }
    post_via_redirect "/bookshelves", bookshelf: test_bookshelf
    assert_response :success
    post_via_redirect "/sessions", name: "TestName", password: "TestPassword"
    assert_response :success

    # make sure there are no books yet
    assert assigns(:book).empty?
    assert assigns(:recent_books).empty?

    # check if there are any books which you can take
    get "/bookshelves/#{session[:bookshelf_id]}/new_pos"
    assert_response :success
    assert_not assigns(:book).empty?

    # get book for your bookshelf and make sure its taken
    assert_difference('Connection.count', 1) do
      patch_via_redirect "/bookshelves/#{session[:bookshelf_id]}/new_pos/#{Book.last.id}"
    end
    assert_response :success
    assert_equal "/bookshelves/#{session[:bookshelf_id]}/new_pos", path
    assert assigns(:book).empty?
    assert flash[:notice].include?("Successfully added new position")

    # log out
    delete_via_redirect "/log_out"
    assert :success
  end

  test "admin adds new book to the library, user creates his bookshelf, adds and removes the book to/from it" do

    # log in as admin, add new book and log out
    get "/"
    post_via_redirect "/sessions", name: "admin", password: "admin"
    test_book = {
        author: "TestAuthor",
        title: "TestTitle",
        cover: Rack::Test::UploadedFile.new(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    assert_difference('Book.count', 1) do
      post_via_redirect "/books", book: test_book
    end
    assert_response :success
    delete_via_redirect "/log_out"
    assert_response :success

    # create new bookshelf and log in to it
    test_bookshelf = {
        name: "TestName",
        password: "TestPassword",
        password_confirmation: "TestPassword"
    }
    post_via_redirect "/bookshelves", bookshelf: test_bookshelf
    assert_response :success
    post_via_redirect "/sessions", name: "TestName", password: "TestPassword"
    assert_response :success

    # go to page where you can take books
    get "/bookshelves/#{session[:bookshelf_id]}/new_pos"
    assert_response :success

    # get one
    assert_difference('Connection.count', 1) do
      patch_via_redirect "/bookshelves/#{session[:bookshelf_id]}/new_pos/#{Book.last.id}"
    end
    assert_response :success

    # go back to your bookshelf and remove taken book
    get "/bookshelves/#{session[:bookshelf_id]}"
    assert_response :success
    assert_not assigns(:book).empty?
    assert_difference('Connection.count', -1) do
      patch_via_redirect "/bookshelves/#{session[:bookshelf_id]}/remove_pos/#{Book.last.id}"
    end
    assert_response :success
    assert assigns(:book).empty?

    # log out
    delete_via_redirect "/log_out"
    assert_response :success
  end

end
