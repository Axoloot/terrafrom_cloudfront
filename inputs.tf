variable "domain" {
  default = "the-finals-roulette.site"
}

variable "bucket_name" {
  default = "the-finals-roulette.site"
}

variable "domain_names" {
  default = ["the-finals-roulette.site", "www.the-finals-roulette.site"]
}

variable "subject_alternative_names" {
  default = [
    "*.the-finals-roulette.site",
    "the-finals-roulette.site",
    "mailer.the-finals-roulette.site",
    "www.the-finals-roulette.site",
  ]
}