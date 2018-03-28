# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ActionController::MimeResponds

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  rescue_from Afip::InvalidRequestError,
    with: :render_external_api_error

  rescue_from Afip::UnsuccessfulResponseError,
    with: :render_external_api_error

  rescue_from Afip::InvalidResponseError,
    with: :render_external_api_error

  rescue_from Afip::ResponseError,
    with: :render_external_api_error

  rescue_from Afip::TimeoutError,
    with: :render_external_api_error

  rescue_from Afip::UnexpectedError,
    with: :render_external_api_error

  before_action :authenticate

  protected

  def render_not_found
    render json: { error: 'Recurso no encontrado' }, status: :not_found
  end

  def render_external_api_error(error)
    render json: { error: error }, status: :bad_gateway
  end

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      @entity = Auth::TokenValidator.new(token).call
    end
  end

  def request_http_token_authentication(_realm = 'Application', _msg = nil)
    render json: { error: 'Token incorrecto' }, status: :unauthorized
  end

  attr_reader :entity
end
