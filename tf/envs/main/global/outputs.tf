output "iam_user_password" {
  value = { for iam_user in module.iam_user : iam_user.user_name => iam_user.this_password }
}

output "iam_user_access_key" {
  value = { for iam_user in module.iam_user : iam_user.user_name => iam_user.access_key }
}

output "iam_user_secret_key" {
  value = { for iam_user in module.iam_user : iam_user.user_name => iam_user.secret_key }
}