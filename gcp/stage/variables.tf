variable "privatekey" {
  type    = string
  default = "../../key-ssh/id_rsa"
}
variable "publickey" {
  type    = string
  default = "../../key-ssh/id_rsa.pub"
}
variable "userssh" {
  type    = string
  default = "valer"
}
variable "network" {
  type    = string
  default = "default"
}
variable "env" {
  type    = string
  default = "stage"
}
variable "project" {
  type    = string
  default = "gcpterraform-18"
}
variable "region" {
  type    = string
  default = "southamerica-east1"
}
variable "key" {
  type    = string
  default = "../key.json"
}
variable "portas" {
  type    = list(any)
  default = ["8080", "80", "22", "443"]
}