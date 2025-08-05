module ImagesHelper
  def render_image(entity)
    if entity.image_url.present?
      image_tag(entity.image_url)
    elsif entity.image.attached?
      image_tag(entity.image)
    elsif entity.is_a?(Lead) && entity.email.present?
      gravatar_image_tag(entity.email)
    end
  end
end
