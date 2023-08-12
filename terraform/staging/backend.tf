terraform {
  backend "s3" {
    bucket                  = ""
    key                     = "awesomenotea-staging/terraform.tfstate"
    region                  = "ap-northeast-1"
  }
}
