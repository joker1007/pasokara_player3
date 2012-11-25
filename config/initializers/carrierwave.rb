if Rails.env.development? || Rails.env.test? || Rails.env.cucumber?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
else
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider               => 'AWS',       # required
      :aws_access_key_id      => ENV["AWS_ACCESS_KEY"],       # required
      :aws_secret_access_key  => ENV["AWS_SECRET_KEY"],       # required
      :region                 => ENV["AWS_S3_REGION"] || 'tokyo'  # optional, defaults to 'us-east-1'
    }
    config.fog_directory  = ENV["AWS_S3_BUCKET_NAME"]                     # required
    config.fog_public     = true                                   # optional, defaults to true
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  end
end
