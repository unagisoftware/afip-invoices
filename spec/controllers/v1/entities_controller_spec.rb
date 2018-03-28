# frozen_string_literal: true

require 'test_helper'
require 'shared_examples/shared_examples_for_controllers'
require 'support/controllers/entities_controller_support'

describe V1::EntitiesController, type: :controller do
  let!(:entity) { create(:entity) }

  before do
    request.headers['HTTP_AUTHORIZATION'] = "Token token=\"#{ENV['AUTH_TOKEN']}\""
  end

  describe 'POST create' do
    subject { post :create, params: { entity: entity_params } }

    it_behaves_like 'HTTP 201 response'

    it 'creates an entity' do
      expect { subject }.to change { Entity.count }.by(1)

      entity = Entity.order(created_at: :asc).last

      entity_params.each do |key, value|
        expect(entity.send(key)).to eq(value)
      end
    end

    context 'when a logo image is received' do
      subject do
        post :create, params: { entity: entity_params(with_logo: true) }
      end

      it 'creates an entity' do
        expect { subject }.to change { Entity.count }.by(1)

        entity = Entity.order(created_at: :asc).last

        expect_entity_logo_to_be_updated(entity)
      end
    end
  end

  describe 'PATCH update' do
    let(:certificate_param) { { certificate: '---CERTIFICATE---' } }

    context "when updating entity's certificate" do
      subject do
        patch :update, params: { id: entity.id, entity: certificate_param }
      end

      it_behaves_like 'HTTP 204 response'

      it "sets entity's certificate" do
        expect { subject }
          .to change { entity.reload.certificate }
          .to(certificate_param[:certificate])
      end
    end

    context "when updating entity's logo" do
      subject do
        patch :update, params: { id: entity.id, entity: { logo: logo_params } }
      end

      it_behaves_like 'HTTP 204 response'

      it "sets entity's logo" do
        subject

        expect_entity_logo_to_be_updated(entity.reload)
      end
    end
  end

  describe 'GET index' do
    subject { get :index }

    it_behaves_like 'HTTP 200 response'

    it 'renders entities details' do
      subject

      data = JSON.parse(response.body)

      expect(data).not_to be_empty

      data.each do |record|
        expect(record.deep_symbolize_keys)
          .to match_valid_format(EntitiesControllerSupport::ENTITY_LONG_FORMAT)
      end
    end
  end

  describe 'GET show' do
    subject { get :show, params: { id: entity.id } }

    it_behaves_like 'HTTP 200 response'

    it 'renders entity details' do
      subject

      data = JSON.parse(response.body).deep_symbolize_keys

      expect(data).to match_valid_format(EntitiesControllerSupport::ENTITY_SHORT_FORMAT)
    end
  end

  private

  def entity_params(with_logo: false)
    params = {
      business_name: 'Pied Piper Inc',
      cuit: '303458431',
      name: 'Pied Piper',
    }

    return params unless with_logo

    params.merge!(logo: logo_params)
  end

  def logo_params
    @logo_params ||= {
      filename: 'image.jpeg',
      content_type: 'image/jpeg',
      data: Base64.encode64(
        File.read(Rails.root.join('spec/support/resources/image.jpeg')),
      ),
    }
  end

  def expect_entity_logo_to_be_updated(entity)
    expect(Base64.encode64(entity.logo.file.read))
      .to eq(logo_params[:data])

    expect(entity.logo.file.content_type)
      .to eq(logo_params[:content_type])

    expect(entity.logo.file.content_type)
      .to eq(logo_params[:content_type])
  end
end
