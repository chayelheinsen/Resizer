# Development

1. Copy `.env.example` to `.env` and fill out the variables with your information.
   Note: The AWS keys need to have full access to S3.
1. `$ bundle install`
1. `$ rails s`

# API
The API is very simple, it just expects a path to the image on S3 that you want to resize.
If your S3 link was `https://s3.amazonaws.com/my-bucket/path/to/image.png`, and you hosted Resizer at `cdn.example.com` you would call
`cdn.example.com/path/to/image.png`.

The API also allows you to resize the image on the fly. Resizing is as simple as passing a width and height
as url params. Calling `cdn.example.com/path/to/image.png?w=200&h=200` will fetch the master image, resize it, and return the resized image.

Resizer is also pretty smart! If the image requested has already been resized, it will just returned the already resized version; no resizing needed. This is done by saving the resized image back to S3. You can find the resized images on your bucket at `/resizer/WIDTHxHEIGHT/ORIGINAL_IMAGE_PATH`.
