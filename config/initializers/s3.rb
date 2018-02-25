# frozen_string_literal: true

S3 = Aws::S3::Resource.new(region: ENV.fetch("AWS_REGION"))
