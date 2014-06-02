class BooksController < ApplicationController

  def index
    if session[:admin]
      @book = Book.all
      @fresh_book = Book.new
    else
      add_flash :error, "Sign in, please"
      redirect_to root_path
    end
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to books_path
    else
      @book.errors.full_messages.each do |err|
        add_flash :error, err
      end
      redirect_to books_path(new_book_err: true)
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private
    def book_params
      params.require(:book).permit(:author, :title, :cover)
    end
end