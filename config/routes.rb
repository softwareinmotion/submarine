Submarine::Application.routes.draw do
  if feature_active? :persist_present_demo
    root :to => 'navigation#index', :as => 'index'
  else
    root :to => 'issues#index', :as => 'index'
  end
  post 'change_list' => 'issues#change_list', :as => 'change_list'
  post 'finish_issue/:id' => 'issues#finish_issue', :as => 'finish_issue'
  post 'activate_issue/:id' => 'issues#activate_issue', :as => 'activate_issue'
  get 'finished_issues' => 'issues#finished_issues_list', :as => 'finished_issues'
  get 'contact_page' => 'navigation#contact_page', :as => 'contact_page'
  get 'impressum' => 'navigation#impressum', :as => 'impressum'
  
  resources :issues
  resources :bugs, :controller => 'issues'
  resources :tasks, :controller => 'issues'
  resources :user_stories, :controller => 'issues'
end
