# frozen_string_literal: true

class ImageFetcher
  attr_reader :image_path, :w, :h
  def initialize(image_path, w:, h:)
    @image_path = image_path
    @w = w
    @h = h
  end

  def call
    return unless image_from_s3.exists?
    image = fetch_image
    return struct_with_image(image) unless can_resize?

    resize(image)

    if save_file(file_from_image(image))
      CachedImageFetcher.new(image_path, w: w, h: h).call
    end
  rescue MiniMagick::Invalid
  end

  private

  def resize(image)
    image.resize("#{w}x#{h}")
  end

  def file_from_image(image)
    image.tempfile.open
  end

  def struct_with_image(image)
    OpenStruct.new(data: image.tempfile.open, content_type: image.mime_type)
  end

  def fetch_image
    MiniMagick::Image.open(image_from_s3.presigned_url(:get))
  end

  def save_file(file)
    S3.bucket(bucket).object(cache_key).upload_file(file)
  end

  def can_resize?
    w && h
  end

  def cache_key
    "resizer/#{w}x#{h}/#{image_path}"
  end

  def bucket
    @bucket ||= ENV.fetch("S3_BUCKET")
  end

  def bucket_path
    @bucket_path ||= "https://s3.amazonaws.com/#{bucket}"
  end

  def image_from_s3
    @image_from_s3 ||= S3.bucket(bucket).object(image_path)
  end
end
