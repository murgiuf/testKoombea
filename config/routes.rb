Rails.application.routes.draw do
  resources :contactos
  resources :cargas
  devise_for :users


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'contactos#index'

  post 'import_carga', to: 'cargas#import_carga'
  get 'modificaMapeo', to: 'cargas#modificaMapeo'
  get 'descarga_archivo', to: 'cargas#descarga_archivo'
end
