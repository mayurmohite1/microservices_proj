variable "region" {
  type = string
  default = "us-east-1"
}

variable "s3bucket_name" {
  type = string
  default = "expense-tracker-1234"
}

variable "dynamo_db_name" {
  type = string
  default = "team1-db_name"
}