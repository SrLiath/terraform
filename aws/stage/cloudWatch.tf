#AWS CloudWatch log stream
resource "aws_cloudwatch_log_group" "stage_log_group" {
  name = "${var.env}_log_group"
}
resource "aws_cloudwatch_log_stream" "stage_log_stream" {
  name           = "${var.env}_log_stream"
  log_group_name = aws_cloudwatch_log_group.stage_log_group.name
}