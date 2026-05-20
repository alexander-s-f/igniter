Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "availability" => "availability#show"
  get "observations/:id" => "observations#show", as: :observation
  root "availability#show"
end
