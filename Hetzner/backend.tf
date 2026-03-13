terraform {
  backend "s3" {
    skip_requesting_account_id = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style            = true
  }
  
}
