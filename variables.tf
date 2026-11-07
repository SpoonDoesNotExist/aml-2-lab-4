variable "network_name" {
  type    = string
  default = "tf-lesson-vpc"
}
variable "subnet_name" {
  type    = string
  default = "tf-lesson-subnet"
}
variable "subnet_cidr" {
  type    = string
  default = "10.10.0.0/24"
}
variable "zone" {
  type    = string
  default = "ru-central1-a"
}
variable "platform_id" {
  type    = string
  default = "standard-v3"
}
variable "cores" {
  type    = number
  default = 2
}
variable "memory" {
  type    = number
  default = 2
}
variable "core_fraction" {
  type    = number
  default = 20
}
variable "disk_size" {
  type    = number
  default = 10
}
variable "disk_type" {
  type    = string
  default = "network-hdd"
}
variable "image_family" {
  type    = string
  default = "ubuntu-2204-lts"
}
variable "web_name" {
  type    = string
  default = "web"
}
variable "worker_name" {
  type    = string
  default = "worker"
}
variable "web_sg_name" {
  type    = string
  default = "tf-lesson-web-sg"
}
variable "worker_sg_name" {
  type    = string
  default = "tf-lesson-worker-sg"
}
variable "ssh_user" {
  type    = string
  default = "student"
}
variable "ssh_public_key_path" {
  type    = string
  default = ".local/id_ed25519.pub"
}
variable "web_image" {
  type    = string
  default = "nginx:stable-alpine"
}
