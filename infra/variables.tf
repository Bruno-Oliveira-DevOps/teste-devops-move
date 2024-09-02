variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
  default     = "fast-banner-433813-r7"
}

variable "region" {
  description = "Região para os clusters GKE"
  type        = string
  default     = "us-central1"
}

variable "network_names" {
  description = "Nomes das VPCs"
  type        = list(string)
  default     = ["vpc-cluster-java", "vpc-cluster-python"]
}

variable "cluster_names" {
  description = "Nomes dos clusters GKE"
  type        = list(string)
  default     = ["gke-cluster-java", "gke-cluster-python"]
}

variable "subnet_names" {
  description = "Nomes das sub-redes"
  type        = list(string)
  default     = ["subnet-cluster-java", "subnet-cluster-python"]
}
