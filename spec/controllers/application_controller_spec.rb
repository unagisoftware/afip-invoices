# frozen_string_literal: true

require 'test_helper'

describe ApplicationController, type: :controller do
  controller do
    def test_unauthorized; end

    def test_record_not_found
      raise ActiveRecord::RecordNotFound
    end

    def test_afip_invalid_request
      raise Afip::InvalidRequestError.new(
        error: build_error,
        http_status_code: 500,
        message: 'parameters',
        response: 'response',
      )
    end

    def test_afip_unsuccessful_response
      raise Afip::UnsuccessfulResponseError.new(
        error: build_error,
        http_status_code: 500,
        message: 'parameters',
        response: 'response',
      )
    end

    def test_afip_invalid_response
      raise Afip::InvalidResponseError.new(
        error: build_error,
        message: 'parameters',
        response: 'response',
      )
    end

    def test_afip_timeout_error
      raise Afip::TimeoutError
    end

    def test_afip_unexpected_error
      raise Afip::UnexpectedError.new(error: build_error)
    end

    private

    def build_error
      object = OpenStruct.new

      object.backtrace = ['path']
      object.to_s = 'error message'

      object
    end
  end

  before :each do
    routes.draw do
      get 'test_unauthorized' => 'anonymous#test_unauthorized'
      get 'test_record_not_found' => 'anonymous#test_record_not_found'
      get 'test_afip_invalid_request' => 'anonymous#test_afip_invalid_request'
      get 'test_afip_unsuccessful_response' => 'anonymous#test_afip_unsuccessful_response'
      get 'test_afip_invalid_response' => 'anonymous#test_afip_invalid_response'
      get 'test_afip_response_error' => 'anonymous#test_afip_response_error'
      get 'test_afip_timeout_error' => 'anonymous#test_afip_timeout_error'
      get 'test_afip_unexpected_error' => 'anonymous#test_afip_unexpected_error'
    end
  end

  context 'when no access token is provided for authentication' do
    it 'returns an HTTP 401 response' do
      get :test_unauthorized

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when access token is provided for authentication' do
    let(:entity) { create(:entity) }

    before do
      request.headers['HTTP_AUTHORIZATION'] = "Token token=\"#{entity.auth_token}\""
    end

    context 'and ActiveRecord::RecordNotFound is raised' do
      it 'returns an HTTP 404 response' do
        get :test_record_not_found

        expect(response).to have_http_status(:not_found)
      end

      it 'renders JSON indicating that resource could not be found' do
        get :test_record_not_found

        error = JSON.parse(response.body)['error']

        expect(error).to eq('Recurso no encontrado')
      end
    end

    context 'and an AFIP error is raised' do
      shared_examples 'AFIP error response' do |error, route|
        it "rescues #{error} returning an HTTP 5022 response" do
          get route

          expect(response).to have_http_status(:bad_gateway)
        end

        it 'renders JSON indicating the error' do
          get route

          error = JSON.parse(response.body)['error']

          expect(error).to include('Error de conexión con AFIP')
        end
      end

      it_behaves_like 'AFIP error response',
        'Afip::InvalidRequestErrorError',
        :test_afip_invalid_request

      it_behaves_like 'AFIP error response',
        'Afip::UnsuccessfulResponseError',
        :test_afip_unexpected_error

      it_behaves_like 'AFIP error response',
        'Afip::InvalidResponseError',
        :test_afip_invalid_response

      it_behaves_like 'AFIP error response',
        'Afip::TimeoutError',
        :test_afip_timeout_error

      it_behaves_like 'AFIP error response',
        'Afip::UnexpectedError',
        :test_afip_unexpected_error
    end
  end
end
