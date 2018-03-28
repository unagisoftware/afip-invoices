# frozen_string_literal: true

Rails.application.routes.draw do
  concern :api do
    resources :entities, only: %i[index create show update]
    resources :afip_people, only: [:show], param: :cuit

    resources :invoices, only: %i[create show index] do
      get :details, on: :collection
      get :export, on: :member
      post :export_preview, on: :collection
    end

    get '/bill_types', to: 'static#bill_types'
    get '/concept_types', to: 'static#concept_types'
    get '/currencies', to: 'static#currencies'
    get '/document_types', to: 'static#document_types'
    get '/iva_types', to: 'static#iva_types'
    get '/sale_points', to: 'static#sale_points'
    get '/tax_types', to: 'static#tax_types'
    get '/optionals', to: 'static#optionals'
    get '/dummy', to: 'static#is_working'
  end

  scope module: 'v1' do
    concerns :api
  end

  namespace :v1 do
    concerns :api
  end
end
