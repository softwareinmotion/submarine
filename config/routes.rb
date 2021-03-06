Submarine::Application.routes.draw do
  resources :questions

  if feature_active? :persist_present_demo
    root :to => 'navigation#index', :as => 'index'
    get 'contact_page' => 'questions#new', :as => 'contact_page'
  else
    root :to => 'issues#new_issues_list', :as => 'index'
    get 'contact_page' => 'navigation#contact_page', :as => 'contact_page'
  end
  post 'change_list' => 'issues#change_list', :as => 'change_list'
  post 'finish_issue/:id' => 'issues#finish_issue', :as => 'finish_issue'
  post 'activate_issue/:id' => 'issues#activate_issue', :as => 'activate_issue'
  get 'finished_issues' => 'issues#finished_issues_list', :as => 'finished_issues'

  get 'new_issues' => 'issues#new_issues_list', :as => 'new_issues'

  get 'impressum' => 'navigation#impressum', :as => 'impressum'
  get 'finished'=> 'questions#finished', :as => 'finished'

  put 'issues/:id' => 'issues#status_handler', :as => 'status_handler'

  resources :issues do
    member { get 'file_attachment' }
  end
  resources :projects do
    member { get 'project_icon' }
  end
  resources :bugs, :controller => 'issues'
  resources :tasks, :controller => 'issues'
  resources :user_stories, :controller => 'issues'
  resources :document, :controller => 'issues'
end
