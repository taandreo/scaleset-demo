variable "automation_account_name" {
  type    = string
  default = "aztaautomation"
}

variable "func_name" {
  type    = string
  default = "aztafunc"
}

variable "vm_size" {
  type = string
  description = "Size for the scaleset instances"
  default = "Standard_F2"
}

variable "admin_pass" {
  type = string
  description = "Admin password"
}