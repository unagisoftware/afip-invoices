# frozen_string_literal: true

class EntityManager
  attr_reader :entity, :params

  def initialize(params:, entity: Entity.new)
    @entity = entity
    @params = sanitize_params(params)
  end

  def create_or_update
    @entity.assign_attributes(params)
    @entity.save!
  end

  private

  def sanitize_params(params)
    if params.key?(:logo)
      file_data = params.delete(:logo)

      params[:logo] = {
        tempfile: temp_file(file_data),
        filename: file_data[:filename],
        content_type: file_data[:content_type],
      }
    end

    params
  end

  def temp_file(file_data)
    temp_file = Tempfile.new(
      [file_data[:filename], ::File.extname(file_data[:filename])],
      encoding: Encoding::BINARY,
    )
    temp_file.binmode
    temp_file.write(Base64.decode64(file_data[:data]))
    temp_file.rewind
    temp_file
  end
end
