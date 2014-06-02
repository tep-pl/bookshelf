require 'test_helper'

class UsersFlowTest < ActionDispatch::IntegrationTest

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  test "admin logs in, browses the site and logs out" do
    get "/"
    assert_response :success

    post_via_redirect "/sessions", name: "admin", password: "admin"
    assert_equal "/books", path
    assert assigns(:book)
    assert assigns(:fresh_book)

    delete_via_redirect "/log_out"
    assert_equal "/", path
    assert flash[:notice].include?("Successfully signed out")
  end

  test "user creates account, browses the site and logs out" do
    get "/"
    assert_response :success

    test_bookshelf = {
        name: "TestName",
        password: "TestPassword",
        password_confirmation: "TestPassword"
    }
    assert_difference('Bookshelf.count', 1) do
      post_via_redirect "/bookshelves", bookshelf: test_bookshelf
    end
    assert_response :success
    assert_equal "/", path
    assert flash[:notice].include?("Feel free to sign in now")

    post_via_redirect "/sessions", name: "TestName", password: "TestPassword"
    assert_response :success
    assert_equal "/bookshelves/#{session[:bookshelf_id]}", path
    assert assigns(:book)
    assert assigns(:recent_books)

    delete_via_redirect "/log_out"
    assert_response :success
    assert_equal "/", path
    assert flash[:notice].include?("Successfully signed out")
  end

end
