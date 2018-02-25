# frozen_string_literal: true

class FetchController < ApplicationController
  before_action :check_cache

  def index
    if image = ImageFetcher.new(image_path, w: width, h: height).call
      send_data(image.data, type: image.content_type, disposition: "inline")
    else
      head 404
    end
  end

  private

  def image_params
    params.permit(:w, :h)
  end

  def check_cache
    if can_resize? && image = cached_image
      send_data(image.data, type: image.content_type, disposition: "inline")
    end
  end

  def image_path
    @image_path ||= request.path.sub("/", "") if request.path.starts_with?("/")
  end

  def cached_image
    CachedImageFetcher.new(
      image_path,
      w: width,
      h: height,
    ).call
  end

  def width
    image_params[:w]
  end

  def height
    image_params[:h]
  end

  def can_resize?
    image_params.has_key?(:w) && image_params.has_key?(:h)
  end
end
