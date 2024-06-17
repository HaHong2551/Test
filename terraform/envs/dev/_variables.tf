variable "project" {
  description = "Name of project"
  type        = string
}
variable "env" {
  description = "Name of project environment"
  type        = string
}
variable "region" {
  description = "Region of environment"
  type        = string
}
variable "pipeline" {
  description = "Deploy by pipeline"
  type        = bool
  default     = false
}
