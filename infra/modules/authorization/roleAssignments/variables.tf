variable "scope" {
  type        = string
  description = "Resource scope on which access is needed"
}

variable "role_id" {
  type        = string
  description = "Role definition id for the respective roles"
  default     = "Reader"
}

variable "role_name" {
  type        = string
  description = "Role definition name for the respective roles"
}

variable "object_id" {
  type        = string
  description = "Object / Principal Id for the user or managed identity."
}
