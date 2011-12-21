if Rails.env.test? or Rails.env.cucumber?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
else
  CarrierWave.configure do |config|
    config.grid_fs_database = Mongoid.database.name
    config.grid_fs_host = Mongoid.config.master.connection.host
    config.storage = :grid_fs
    config.grid_fs_access_url = "/gridfs"
  end
end
