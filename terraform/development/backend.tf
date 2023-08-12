terraform {
  backend "s3" {
    bucket                  = ""
    key                     = "awesomenotea-development/terraform.tfstate"
    region                  = "ap-northeast-1"
  }
}
