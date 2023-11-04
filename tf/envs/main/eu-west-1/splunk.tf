resource "aws_sqs_queue" "splunk-cloudtrail" {
  name                      = "devops-splunk-cloudtrail"
  message_retention_seconds = 86400
}

# Allow S3 bucket to send messages to SQS queue
resource "aws_sqs_queue_policy" "splunk-cloudtrail-policy" {
  queue_url = aws_sqs_queue.splunk-cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "sqs:SendMessage",
      Resource  = aws_sqs_queue.splunk-cloudtrail.arn,
      Condition = {
        ArnLike = {
          "aws:SourceArn" = "arn:aws:s3:::logs.devops.co.uk"
        }
      }
    }]
  })
}

resource "aws_s3_bucket_notification" "splunk-cloudtrail-notification" {
  bucket = "logs.devops.co.uk"

  queue {
    queue_arn     = aws_sqs_queue.splunk-cloudtrail.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "cloudtrail/AWSLogs/123456789876/"
  }
}