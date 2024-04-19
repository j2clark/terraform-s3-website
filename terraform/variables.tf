variable "domain_name" {
  type        = string
  description = "The actual domain name, e.g. example.com"
}

variable "bucket_name" {
  type        = string
  description = "The S3 bucket used to host application. Usually the same name as the domain_name, e.g. example.com"
}

variable "github_repo" {
  type        = string
  description = "The name of the github repository to be deployed. e.g. some_user/my_example_website"
}

variable "branch" {
  type        = string
  description = "The github repository branch to be deployed"
  default     = "main"
}


variable "common_tags" {
  type        = map(string)
  description = "Common tags you want applied to all components."
  default     = {
#    Domain = "example.com"
#    Application = "Frontend"
#    Repo        = "some_user/my_example_website"
  }
}