variable "name" { 
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure location"  
}

variable "tags" {
  type        = map(string)
  description = "Tags for resource group"
}
