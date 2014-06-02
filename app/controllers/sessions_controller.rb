class SessionsController < ApplicationController

  def new
    if session[:admin]
      redirect_to books_path
    elsif session[:bookshelf_id]
      redirect_to bookshelf_path(session[:bookshelf_id])
    elsif mobile_device?
      @fresh_bookshelf = Bookshelf.new
      @bookshelf = Bookshelf.all
      @bookshelf = @bookshelf.sort{ |x,y|
        if x.name > y.name
          1
        elsif x.name < y.name
          -1
        else
          0
        end
      }
    else
      @fresh_bookshelf = Bookshelf.new
    end
  end

  def create
    if params[:name] == 'admin' && params[:password] == 'admin'
      session[:admin] = true
      redirect_to books_path
    else
      bookshelf = Bookshelf.authenticate(params[:name], params[:password])
      if bookshelf
        session[:bookshelf_id] = bookshelf.id
        session[:pos_changes] = bookshelf.pos_changes
        bookshelf.persist_login
        redirect_to bookshelf_path(bookshelf)
      elsif !mobile_device? && Bookshelf.where(name: params[:name]).exists?
        add_flash :error, "Invalid name/password combination"
        redirect_to bookshelf_path(Bookshelf.find_by_name(params[:name]))
      else
        add_flash :error, "Invalid name/password combination"
        redirect_to root_path(sg_in_err: "name_#{params[:name]}")
      end
    end
  end

  def destroy
    if session[:admin]
      session[:admin] = nil
    else
      session[:bookshelf_id] = nil
    end
    add_flash :notice, "Successfully signed out"
    redirect_to root_path
  end

end
