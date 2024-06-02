terraform {
  backend "s3" {
    bucket         = "p2-revhire-s3-bucket"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "p2-dynamo-db"
    encrypt = true
  }
}
