terraform{
    backend "s3"{
        bucket  = "roboshopbucket"
        key     = "roboshopbucket/projectdeploy/terraform.tfstate"
        region  = "us-east-1"
        dynamodb_table = "terraform1"
    }
}



provider "aws" {
    region = "us-east-1"
}