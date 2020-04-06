variable "region" {
  description = "The region you are deploying into - only relevant for consul"
  type        = string
  default     = ""
}

variable "disable_ipv6" {
  description = "Disable ipv6 in grub"
  type        = bool
  default     = true
}

variable "consul_enabled" {
  description = "Enable consul service"
  type        = bool
  default     = false
}

variable "node_tags" {
  description = "The tag to put into the node exporter for consul to pick up the tag of the instance and associate the proper metrics"
  type        = string
  default     = "prep"
}

variable "prometheus_enabled" {
  description = "Download and start node exporter"
  type        = bool
  default     = false
}

variable "type" {
  description = "Type of node - ie sentry / validator, - more to come"
  type        = string
  default     = "sentry"
}

variable "cloud_provider" {
  description = "What provider is this node running on?"
  type        = string
}

//------------- Volume

variable "driver_type" {
  description = "The ebs volume driver - nitro or standard"
  type        = string
  default     = "nitro"
}

variable "mount_volumes" {
  description = "Boolean to mount volume"
  type        = bool
  default     = true
}