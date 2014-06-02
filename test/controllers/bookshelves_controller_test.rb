require 'test_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

class BookshelvesControllerTest < ActionController::TestCase

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  test "should create new bookshelf" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }

    assert_difference('Bookshelf.count', 1) do
      post :create, bookshelf: attributes
    end
    assert_redirected_to "/"
    assert flash[:notice].include?("Feel free to sign in now")
  end

  test "should not create bookshelf with name: admin" do
    attributes = { name: "admin", password: "TestPassword", password_confirmation: "TestPassword" }

    assert_difference('Bookshelf.count', 0) do
      post :create, bookshelf: attributes
    end
    assert_redirected_to "/?sg_up_err=true"
    assert flash[:error].include?("Name has already been taken")
  end

  test "should not create bookshelf without name" do
    attributes = { password: "TestPassword", password_confirmation: "TestPassword" }

    assert_difference('Bookshelf.count', 0) do
      post :create, bookshelf: attributes
    end
    assert_redirected_to "/?sg_up_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create bookshelf without password" do
    attributes = { name: "TestName", password_confirmation: "TestPassword" }

    assert_difference('Bookshelf.count', 0) do
      post :create, bookshelf: attributes
    end
    assert_redirected_to "/?sg_up_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create bookshelf without password confirmation" do
    attributes = { name: "TestName", password: "TestPassword" }

    assert_difference('Bookshelf.count', 0) do
      post :create, bookshelf: attributes
    end
    assert_redirected_to "/?sg_up_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create bookshelf without name and password" do
    assert_difference('Bookshelf.count', 0) do
      post :create, bookshelf: { password_confirmation: "TestPassword" }
    end
    assert_redirected_to "/?sg_up_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create bookshelf without password and password confirmation" do
    assert_difference('Bookshelf.count', 0) do
      post :create, bookshelf: { name: "TestName" }
    end
    assert_redirected_to "/?sg_up_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create bookshelf without name and password confirmation" do
    assert_difference('Bookshelf.count', 0) do
      post :create, bookshelf: { password: "TestPassword" }
    end
    assert_redirected_to "/?sg_up_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create bookshelf with not matching password confirmation" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPasswordBad" }

    assert_difference('Bookshelf.count', 0) do
      post :create, bookshelf: attributes
    end
    assert_redirected_to "/?sg_up_err=true"
    assert_not flash[:error].empty?
  end

  test "should not create bookshelf with duplicated name" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }

    assert_difference('Bookshelf.count', 1) do
      post :create, bookshelf: attributes
    end
    assert_difference('Bookshelf.count', 0) do
      post :create, bookshelf: attributes
    end
    assert_redirected_to "/?sg_up_err=true"
    assert_not flash[:error].empty?
  end

  test "should load proper bookshelf page" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.save
    session[:bookshelf_id] = bookshelf.id

    get :show, id: bookshelf.id
    assert assigns(:bookshelf)
    assert assigns(:recent_books)
    assert assigns(:book)
    assert_response :success
  end

  test "should not load bookshelf page without proper credentials" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.save

    get :show, id: bookshelf.id
    assert_not assigns(:bookshelf)
    assert_not assigns(:recent_books)
    assert_not assigns(:book)
  end

  test "should load recent and another books properly" do
    bookshelf_attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(bookshelf_attributes)

    first_book_attributes = {
        author: "TestAuthor",
        title: "TestTitleFirst",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    first_book = Book.new(first_book_attributes)

    second_book_attributes = {
        author: "TestAuthor",
        title: "TestTitleSecond",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    second_book = Book.new(second_book_attributes)

    session[:pos_changes] = Time.now.utc
    bookshelf.books << first_book
    bookshelf.save
    bookshelf.last_login = Time.now.utc
    bookshelf.books << second_book
    bookshelf.save
    session[:bookshelf_id] = bookshelf.id

    get :show, id: bookshelf.id
    assert assigns(:bookshelf)
    assert assigns(:recent_books).include?(first_book)
    assert assigns(:book).include?(second_book)
    assert_response :success
  end

  test "should load proper new position page" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.save
    session[:bookshelf_id] = bookshelf.id

    get :new_pos, id: bookshelf.id
    assert assigns(:bookshelf)
    assert assigns(:book)
    assert_response :success
  end

  test "should not load new position page without proper credentials" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.save

    get :new_pos, id: bookshelf.id
    assert_not assigns(:bookshelf)
    assert_not assigns(:book)
  end

  test "should display on new position page only these books which are not already taken" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)

    first_book_attributes = {
        author: "TestAuthor",
        title: "TestTitleFirst",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    first_book = Book.new(first_book_attributes)

    second_book_attributes = {
        author: "TestAuthor",
        title: "TestTitleSecond",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    second_book = Book.new(second_book_attributes)
    second_book.save

    bookshelf.books << first_book
    bookshelf.save
    session[:bookshelf_id] = bookshelf.id

    get :new_pos, id: bookshelf.id
    assert assigns(:bookshelf)
    assert_not assigns(:book).include?(first_book)
    assert assigns(:book).include?(second_book)
    assert_response :success
  end

  test "should add new position to bookshelf properly" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.save

    book_attributes = {
        author: "TestAuthor",
        title: "TestTitle",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    book = Book.new(book_attributes)
    book.save

    assert_difference('bookshelf.books.size', 1) do
      patch :add_pos, id: bookshelf.id, book_id: book.id
    end
    assert_redirected_to "/bookshelves/#{bookshelf.id}/new_pos"
    assert flash[:notice].include?("Successfully added new position")
  end

  test "should remove position from bookshelf properly" do
    attributes = { name: "TestName", password: "TestPassword", password_confirmation: "TestPassword" }
    bookshelf = Bookshelf.new(attributes)
    bookshelf.save

    book_attributes = {
        author: "TestAuthor",
        title: "TestTitle",
        cover: File.open(File.join(Rails.root, '/test/fixtures/files/cover.gif'))
    }
    book = Book.new(book_attributes)
    book.save

    assert_difference('bookshelf.books.size', 1) do
      patch :add_pos, id: bookshelf.id, book_id: book.id
    end
    assert_difference('bookshelf.books.size', -1) do
      patch :remove_pos, id: bookshelf.id, book_id: book.id
    end
    assert_redirected_to "/bookshelves/#{bookshelf.id}"
  end

end