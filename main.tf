# S3 bucket to hold terraform state
data "aws_s3_bucket" "terraform_state" {
  bucket = var.tfstate_bucket_name
}

resource "aws_kms_key" "tfstatekey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = data.aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tfstatekey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# A private key pair for SSH instance authentication
resource "aws_key_pair" "sample-kp-config-user" {
  key_name   = "sample-user"
  public_key = file(var.public_key)
}
