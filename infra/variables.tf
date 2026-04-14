# Input Variables

variable "docker_image_tag" {
  description = "Docker image tag to deploy (commit SHA from CI/CD, or 'latest' for local runs)"
  type        = string
  default     = "latest"
}
