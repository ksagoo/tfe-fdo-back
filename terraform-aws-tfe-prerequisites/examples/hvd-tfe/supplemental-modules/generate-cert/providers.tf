provider "aws" {
  region = var.region
}

provider "acme" {
  #server_url = "https://acme-staging-v02.api.letsencrypt.org/directory" #staging
  server_url = "https://acme-v02.api.letsencrypt.org/directory" #prod
}