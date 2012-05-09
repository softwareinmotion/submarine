Submarine::Application.routes.draw do
  resources :questions

  if feature_active? :persist_present_demo
    root :to => 'navigation#index', :as => 'index'
    get 'contact_page' => 'questions#new', :as => 'contact_page'
  else
    root :to => 'issues#index', :as => 'index'
  end
  post 'change_list' => 'issues#change_list', :as => 'change_list'
  post 'finish_issue/:id' => 'issues#finish_issue', :as => 'finish_issue'
  post 'activate_issue/:id' => 'issues#activate_issue', :as => 'activate_issue'
  get 'finished_issues' => 'issues#finished_issues_list', :as => 'finished_issues'
  post 'toggle_list_locks' => 'issues#toggle_list_locks'
  post 'extend_lock_time' => 'issues#extend_lock_time'

  get 'contact_page' => 'navigation#contact_page', :as => 'contact_page'
  get 'impressum' => 'navigation#impressum', :as => 'impressum'
  
  resources :issues
  resources :bugs, :controller => 'issues'
  resources :tasks, :controller => 'issues'
  resources :user_stories, :controller => 'issues'
end
