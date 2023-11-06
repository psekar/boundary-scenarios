terraform {
  required_providers {
    boundary = {
      source = "hashicorp/boundary"
      version = "~> 1.1.10"
    }
  }
}

provider "boundary" {
  addr = var.boundary_host
  auth_method_login_name = var.boundary_admin_user
  auth_method_password = var.boundary_admin_password
}

resource "boundary_scope" "org" {
  name                     = "devops-tf"
  description              = "Devops Organization"
  scope_id                 = "global"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_auth_method" "password" {
    scope_id = boundary_scope.org.id
    type     = "password"
    name     = "password"
    description = "Password Auth Method"
}

resource "boundary_account_password" "devadmin1" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "devadmin1"
  password       = "$uper$ecure"
}

resource "boundary_user" "devadmin1" {
  name        = "devadmin1"
  description = "Dev Admin User Resource"
  account_ids = [boundary_account_password.devadmin1.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_account_password" "intadmin1" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "intadmin1"
  password       = "$uper$ecure"
}

resource "boundary_user" "intadmin1" {
  name        = "intadmin1"
  description = "Int Admin User Resource"
  account_ids = [boundary_account_password.intadmin1.id]
  scope_id    = boundary_scope.org.id
}

# Configure project 1 with target, credential store and team admin role
resource "boundary_scope" "project1" {
  name                     = "dev"
  description              = "Devops Project"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_target" "dev_ssh" {
    name        = "dev_ssh"
    description = "Dev SSH Target"
    type        = "ssh"
    scope_id    = boundary_scope.project1.id
    address     = "localhost"
}

resource "boundary_credential_store_static" "dev_static" {
    name        = "dev_static"
    description = "Dev Static Credential Store"
    scope_id    = boundary_scope.project1.id
}

resource "boundary_credential_username_password" "dev_static_username_password" {
  name                = "dev_static_username_password"
  description         = "username password credential!"
  credential_store_id = boundary_credential_store_static.dev_static.id
  username            = "my-username"
  password            = "my-password"
}

resource "boundary_role" "devadmin" {
    name        = "devadmin"
    description = "Dev Admin Role"
    scope_id    = boundary_scope.project1.id
    principal_ids = [boundary_user.devadmin1.id]
    grant_strings = [ 
        "id=*;type=target;actions=list,no-op",
        "id=*;type=credential;actions=list,read,create,update,delete",
        "id=*;type=credential-store;actions=list,no-op",
        "id=*;type=session;actions=read:self,cancel:self",
        "id=${boundary_target.dev_ssh.id};actions=read,update,authorize-session,set-credential-sources,add-credential-sources,remove-credential-sources",
        "id=${boundary_credential_store_static.dev_static.id};actions=read,update",
    ]
}

# Configure 2nd credential store in same project with credential

resource "boundary_credential_store_static" "dev_static2" {
    name        = "dev_static2"
    description = "Dev Static Credential Store 2"
    scope_id    = boundary_scope.project1.id
}

resource "boundary_credential_username_password" "dev_static_username_password2" {
  name                = "dev_static_username_password2"
  description         = "username password credential!"
  credential_store_id = boundary_credential_store_static.dev_static2.id
  username            = "my-username"
  password            = "my-password"
}
