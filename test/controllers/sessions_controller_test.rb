require 'test_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

class SessionsControllerTest < ActionController::TestCase

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  test "should return new session page properly" do
    get :new
    assert assigns(:fresh_bookshelf)
    assert :success
  end

  test "should create new session for admin" do
    post :create, name: 'admin', password: 'admin'
    assert session[:admin]
    assert_redirected_to "/books"
  end

  test "should create proper session for user" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.pos_changes = Time.now
    bookshelf.save
    post :create, name: bookshelf.name, password: bookshelf.password
    assert session[:bookshelf_id]
    assert session[:pos_changes]
    assert_redirected_to "/bookshelves/#{bookshelf.id}"
  end

  test "should not create session without password" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.pos_changes = Time.now
    bookshelf.save
    post :create, name: bookshelf.name, password: ""
    assert_not session[:bookshelf_id]
    assert_not session[:pos_changes]
    assert_redirected_to "/bookshelves/#{bookshelf.id}"
    assert flash[:error].include?("Invalid name/password combination")
  end

  test "should not create session without name" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.pos_changes = Time.now
    bookshelf.save
    post :create, name: "", password: bookshelf.password
    assert_not session[:bookshelf_id]
    assert_not session[:pos_changes]
    assert_redirected_to "/?sg_in_err=name_"
    assert flash[:error].include?("Invalid name/password combination")
  end

  test "should not create session with bad password" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.pos_changes = Time.now
    bookshelf.save
    post :create, name: bookshelf.name, password: "TestPasswordBad"
    assert_not session[:bookshelf_id]
    assert_not session[:pos_changes]
    assert_redirected_to "/bookshelves/#{bookshelf.id}"
    assert flash[:error].include?("Invalid name/password combination")
  end

  test "should properly clean admin session" do
    session[:admin] = true

    delete :destroy
    assert_not session[:admin]
    assert_redirected_to "/"
    assert flash[:notice].include?("Successfully signed out")
  end

  test "should properly clean normal session" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.pos_changes = Time.now
    bookshelf.save
    session[:bookshelf_id] = bookshelf.id

    delete :destroy
    assert_not session[:bookshelf_id]
    assert_redirected_to "/"
    assert flash[:notice].include?("Successfully signed out")
  end

end