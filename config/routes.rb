# frozen_string_literal: true

Rails.application.routes.draw do
  get "*path", to: "fetch#index"
end
