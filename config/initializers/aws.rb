Aws.config.update({
  region: ENV['EXAM_AWS_REGION'],
  credentials: Aws::Credentials.new(ENV['EXAM_AWS_ACCESS_KEY_ID'], ENV['EXAM_AWS_SECRET_ACCESS_KEY']),
})

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['EXAM_AWS_BUCKET'])
