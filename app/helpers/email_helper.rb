module EmailHelper
  def email_image_tag(image, **options)
    attachments.inline[image] = File.read(Rails.root.join("app/assets/email_images/#{image}"))
    image_tag attachments[image].url, **options
  end

  def google_map(address_postal)
    image_tag "https://maps.googleapis.com/maps/api/staticmap?zoom=16&size=600x300&markers=#{address_postal}&key=#{ENV['M_I_Y']}"
  end

  def google_map_direction(origin, destination)
    return "https://www.google.com/maps/dir/#{origin}/#{destination}"
  end

  def profile_image_tag(image, **options)
    if image.first(20) == '/default_profile_pic'
      attachments.inline[image] = File.read(Rails.root.join("app/assets/default_profile_pic/default_profile_pic.png"))
    else
      attachments.inline[image] = File.read(Rails.root.join("public/#{image}"))
    end
    image_tag attachments[image].url, **options
  end
  #def send_email email, whatever
  #    attachments[whatever.attachment.file.filename.to_s] = whatever.attachment.read
  #    mail(to: email, subject: whatever.subject)
  #  end

  #
end
