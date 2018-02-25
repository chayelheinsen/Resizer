class ImageFetcher
  attr_reader :image_path, :w, :h
  def initialize(image_path, w:, h:)
    @image_path = image_path
    @w = w
    @h = h
  end

  def call
    return unless image_from_s3.exists?
    data = MiniMagick::Image.open(image_from_s3.presigned_url(:get))

    if w && h
      data.resize("#{w}x#{h}")
      file = data.tempfile.open

      if S3.bucket(bucket).object(cache_key).upload_file(file)
        CachedImageFetcher.new(image_path, w: w, h: h).call
      end
    else
      OpenStruct.new(data: data.tempfile.open, content_type: data.mime_type)
    end
  end

  private

  def cache_key
    "resizer/#{w}x#{h}/#{image_path}"
  end

  def bucket
    @bucket ||= ENV.fetch('S3_BUCKET')
  end

  def bucket_path
    @bucket_path ||= "https://s3.amazonaws.com/#{bucket}"
  end

  def image_from_s3
    @image_from_s3 ||= S3.bucket(bucket).object(image_path)
  end
end
