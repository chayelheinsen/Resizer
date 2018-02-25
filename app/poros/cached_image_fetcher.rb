class CachedImageFetcher
  attr_reader :image_path, :w, :h
  def initialize(image_path, w:, h:)
    @image_path = image_path
    @w = w
    @h = h
  end

  def call
    object = cached_image_from_s3

    if object.exists?
      data = MiniMagick::Image.open(object.presigned_url(:get))
      OpenStruct.new(data: data.tempfile.open, content_type: object.content_type)
    end
  end

  private

  def bucket
    @bucket ||= ENV.fetch('S3_BUCKET')
  end

  def bucket_path
    @bucket_path ||= "https://s3.amazonaws.com/#{bucket}"
  end

  def cached_s3_key
    "resizer/#{w}x#{h}/#{image_path}"
  end

  def cached_image_from_s3
    S3.bucket(bucket).object(cached_s3_key)
  end
end
