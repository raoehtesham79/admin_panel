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
      get 'dashboard'
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

  authenticated :user, lambda { |u| u.admin } do
    root 'posts#dashboard', as: :admin_dashboard
  end

  authenticated :user, lambda { |u| u.editor } do
    root to: 'posts#index', as: :editor_dashboard
  end

  root 'posts#welcome'
end
