# frozen_string_literal: true

module V1
  class EntitiesController < AdminController
    before_action :fetch_entity, only: %i[show update]

    def create
      manager = EntityManager.new(params: create_params)

      if manager.create_or_update
        render json: GeneratedEntityRepresenter.new(manager.entity),
          status: :created
      else
        render json: { errors: entity.errors }, status: :bad_request
      end
    end

    def update
      manager = EntityManager.new(params: update_params, entity: @entity)

      if manager.create_or_update
        head :no_content
      else
        render json: { error: 'Error al actualizar certificado' },
          status: :bad_request
      end
    end

    def index
      render json: EntityRepresenter
        .for_collection
        .new(Entity.by_name)
    end

    def show
      render json: @entity
    end

    private

    def fetch_entity
      @entity = Entity.find(params[:id])
    end

    def create_params
      params.require(:entity).permit(
        :name,
        :business_name,
        :cuit,
        logo: %i[filename content_type data],
      )
    end

    def update_params
      params.fetch(:entity, {}).permit(
        :certificate,
        logo: %i[filename content_type data],
      )
    end
  end
end
