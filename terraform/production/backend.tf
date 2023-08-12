terraform {
  backend "s3" {
    bucket                  = ""
    key                     = "awesomenotea-production/terraform.tfstate"
    region                  = "ap-northeast-1"
  }
}
