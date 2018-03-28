# frozen_string_literal: true

class AdminController < ApplicationController
  protected

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      token == ENV['AUTH_TOKEN']
    end
  end
end
