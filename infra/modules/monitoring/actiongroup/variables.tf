variable "location" {
  type    = string
  default = "uksouth"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "action_group_name" {
  description = "Name of the Action Group"
  type        = string
}

variable "email_receivers" {
  description = "List of email receivers"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "sms_receivers" {
  description = "List of SMS receivers"
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = []
}

variable "voice_receivers" {
  description = "List of voice call receivers"
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = []
}
