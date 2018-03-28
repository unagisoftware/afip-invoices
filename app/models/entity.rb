# frozen_string_literal: true

class Entity < ApplicationRecord
  include Encryptable

  mount_uploader :logo, LogoUploader

  validates :name, presence: true
  validates :business_name, presence: true, uniqueness: true
  validates :cuit, presence: true, uniqueness: { case_sensitive: false }

  attr_encrypted :auth_token

  has_many :invoices, dependent: :destroy

  before_create :set_afip_data, :set_auth_token

  scope :by_name, -> { order(:name) }

  def as_json(options = {})
    options[:only] = %i[id name business_name cuit csr]
    options[:methods] = [:logo_url]
    super
  end

  private

  def set_afip_data
    data = Afip::EntityDataGenerator.new(self).call

    self.private_key = data[:pkey]
    self.csr         = data[:csr].to_s
  end

  def set_auth_token
    self.auth_token = SecureRandom.uuid
  end

  def logo_url
    return if logo.blank?

    "data:#{logo.file.content_type};base64,#{Base64.encode64(logo.file.read)}"
  end
end
