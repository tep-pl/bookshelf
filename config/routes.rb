Bkshelf::Application.routes.draw do

  root 'sessions#new'

  resources :bookshelves, except: [:index, :new, :edit, :update, :delete, :destroy]
  resources :books, except: [:show, :edit, :update]
  resources :sessions, except: [:index, :show, :new, :edit, :update, :delete]

  delete 'log_out', to: 'sessions#destroy', as: 'log_out'

  patch 'bookshelves/:id/remove_pos/:book_id', to: 'bookshelves#remove_pos', as: 'remove_pos_bookshelf'

  get 'bookshelves/:id/new_pos', to: 'bookshelves#new_pos', as: 'new_pos_bookshelf'

  patch 'bookshelves/:id/new_pos/:book_id', to: 'bookshelves#add_pos', as: 'add_pos_bookshelf'

end