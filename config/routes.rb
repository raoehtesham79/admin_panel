Rails.application.routes.draw do
  resources :posts do
    member do
      patch 'approve'
      patch 'reject'
      patch 'publish'
    end

    collection do
      get 'draft'
      get 'rejected'
      get 'approved'
      get 'published'
    end
  end

  devise_for :users
  resources :users, only: [:index, :destroy] do
    member do
      get 'edit_role'
      patch 'update_role'
    end
  end
  devise_scope :user do
    get 'users/sign_out' => 'devise/sessions#destroy'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  authenticated :user do
    root to: 'posts#welcome', as: :authenticated_root
  end

  unauthenticated :user do
    root to: 'posts#welcome', as: :unauthenticated_root
  end
end
