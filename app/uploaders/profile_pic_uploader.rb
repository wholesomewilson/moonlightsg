class ProfilePicUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  include Cloudinary::CarrierWave
  # Choose what kind of storage to use for this uploader:
  #storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  #def store_dir
  #  "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  #end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  process :convert => 'jpg'

  #def default_url(*args)
  #  ActionController::Base.helpers.asset_url("default_profile_pic/default_profile_pic.png")
  #end

   # Create different versions of your uploaded files:
   #version :thumb do
   #   process :my_resize => [315, 410]
   # end

   # Add a white list of extensions which are allowed to be uploaded.
   # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    "#{original_filename}.jpg"
  end

  def public_id
    puts model
    return "avatar/" + model.id.to_s
  end
end
