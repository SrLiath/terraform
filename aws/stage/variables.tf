variable "env"{
    type = string
    default = "stage"
}
variable "region"{
    type = string
    default = "sa-east-1"
}
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