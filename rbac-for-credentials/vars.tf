variable "boundary_host" {
    description = "Value for Boundary Controller Endpoint"
    type        = string
    default = "http://localhost:9200"
}

variable "boundary_admin_user" {
    description = "Value for Boundary Admin User"
    type        = string
    default = "admin"
}

variable "boundary_admin_password" {
    description = "Value for Boundary Admin Password"
    type        = string
    default = "password"
}