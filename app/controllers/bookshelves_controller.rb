class BookshelvesController < ApplicationController

  def create
    if params[:bookshelf][:name] == "admin"
      add_flash :error, "Name has already been taken"
      redirect_to root_path(sg_up_err: true)
    else
      @bookshelf = Bookshelf.new(bookshelf_params)
      if @bookshelf.save
        add_flash :notice, "Feel free to sign in now"
        redirect_to root_path
      else
        @bookshelf.errors.full_messages.each do |err|
          add_flash :error, err
        end
        redirect_to root_path(sg_up_err: true)
      end
    end
  end

  def show
    if session[:bookshelf_id].to_s == params[:id]
      @bookshelf = Bookshelf.find(params[:id])
      if session[:pos_changes] != nil
        @recent_books = @bookshelf.books.find_all { |book|
          creation_time = book.connections.find_by_bookshelf_id(@bookshelf).created_at
          creation_time >= session[:pos_changes] && creation_time <= @bookshelf.last_login
        }
        @book = @bookshelf.books.find_all { |book|
          creation_time = book.connections.find_by_bookshelf_id(@bookshelf).created_at
          creation_time < session[:pos_changes] || creation_time > @bookshelf.last_login
        }
      else
        @recent_books = []
        @book = @bookshelf.books
      end
    elsif !mobile_device?
      empty_desktop_session
    else
      empty_mobile_session
    end
  end

  def new_pos
    if session[:bookshelf_id].to_s == params[:id]
      @bookshelf = Bookshelf.find(params[:id])
      @book = Book.all.find_all{|book| !@bookshelf.books.include?(book)}
    elsif !mobile_device?
      empty_desktop_session
    else
      empty_mobile_session
    end
  end

  def add_pos
    @bookshelf = Bookshelf.find(params[:id])
    @book = Book.find(params[:book_id])

    @bookshelf.books << @book
    @bookshelf.update_columns(pos_changes: @bookshelf.last_login)
    add_flash :notice, "Successfully added new position"
    redirect_to new_pos_bookshelf_path(@bookshelf)
  end

  def remove_pos
    @bookshelf = Bookshelf.find(params[:id])
    @book = @bookshelf.books.find(params[:book_id])

    @bookshelf.books.delete(@book)
    redirect_to @bookshelf
  end

  private
    def bookshelf_params
      params.require(:bookshelf).permit(:name, :password, :password_confirmation)
    end

    def empty_desktop_session
      if Bookshelf.where(id: params[:id]).exists?
        render 'sessions/_create', locals: { name: Bookshelf.find(params[:id]).name }
      else
        add_flash :error, "Bookshelf with id #{params[:id]} doesn't exist"
        redirect_to root_path
      end
    end

    def empty_mobile_session
      add_flash :error, "Sign in, please"
      redirect_to root_path
    end
end