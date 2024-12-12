variable "bucket_name" {
  type = string
}

variable "origin_id" {
  type = string
}

variable "iam_user" {
  description = "Map of IAM User Values, Valid Name for IAM User, Policy will be named '$NAME-policy"
  type        = map(any)
  // Create is set
  validation {
    condition     = can(var.iam_user.create)
    error_message = "Error: var.iam_user.create must be set to true or false"
  }
  // create is valid
  validation {
    condition     = can(regex("^false|true$", var.iam_user.create))
    error_message = "Error: var.iam_user.create must be true or false"
  }
  // name is set
  validation {
    condition     = can(var.iam_user["name"]) || can(regex("^false$", var.iam_user.create))
    error_message = "Error: var.iam_user.name must be specified when create is true"
  }
}

variable "tags" {
  description = "Set of Tags for Bucket and User"
  type        = map(string)
  default = {
    Terraform = "True"
  }
}