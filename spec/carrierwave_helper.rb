require 'fileutils'

carrierwave_root = Rails.root.join('spec', 'support', 'carrierwave')

# Carrierwave configuration is set here instead of in initializer
CarrierWave.configure do |config|
  config.root = carrierwave_root
  config.enable_processing = false
  config.storage = :file
  config.cache_dir = Rails.root.join('spec', 'support', 'carrierwave', 'carrierwave_cache')
end

at_exit do
  Dir.glob(carrierwave_root.join('*')).each do |dir|
    FileUtils.remove_entry(dir)
  end
end
