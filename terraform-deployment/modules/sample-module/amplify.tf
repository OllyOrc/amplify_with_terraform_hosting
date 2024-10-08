# Relevant values:
# - AWS Region
# - Cognito User Pool ID
# - Cognito Web Client ID
# - Cognito Identity Pool ID
# - AppSync GraphQL Region
# - AppSync GraphQL Endpoint ID
# - AppSync GraphQL Authentication Type ('AMAZON_COGNITO_USER_POOLS')
# - Relevant S3 Buckets

# resource "aws_secretsmanager_secret" "github_access_token" {
#   name                    = "github_access_token"
# }

# resource "aws_secretsmanager_secret_version" "github_access_token_secret" {
#   secret_id = aws_secretsmanager_secret.github_access_token.id
#   # tfsec:ignore:GEN003 - Store generated password in a secret
#   secret_string = jsonencode(

#     {
#       "access_token"             = var.ssm_github_access_token_name
#       })
# }


resource "aws_amplify_app" "app" {
  count      = var.create_amplify_app ? 1 : 0
  name       = var.app_name
  repository = var.create_codecommit_repo ? aws_codecommit_repository.codecommit_repo[0].clone_url_http : var.existing_repo_url
  # Auto Branch
  enable_auto_branch_creation   = var.enable_auto_branch_creation
  enable_branch_auto_deletion   = var.enable_auto_branch_deletion
  auto_branch_creation_patterns = var.auto_branch_creation_patterns // default is just main
  auto_branch_creation_config {
    enable_auto_build           = var.enable_auto_build
    enable_pull_request_preview = var.enable_amplify_app_pr_preview
    enable_performance_mode     = var.enable_performance_mode
    framework                   = var.framework
  }
  # OPTIONAL - Necessary if not using oauth_token or access_token (used for GitLab and GitHub repos)
  iam_service_role_arn = var.create_codecommit_repo ? aws_iam_role.amplify_codecommit[0].arn : null
  access_token         = var.lookup_ssm_github_access_token ? data.aws_ssm_parameter.ssm_github_access_token[0].value : var.github_access_token // optional, only needed if using github repo
  # access_token = aws_secretsmanager_secret.github_access_token_secret.access_token


  build_spec = var.path_to_build_spec != null ? file("${path.root}/${var.path_to_build_spec}") : file("${path.root}/../amplify.yml")
  # build_spec = file("${path.root}/../amplify.yml")
  # Redirects for Single Page Web Apps (SPA)
  # https://docs.aws.amazon.com/amplify/latest/userguide/redirects.html#redirects-for-single-page-web-apps-spa
  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|ttf|map|json)$)([^.]+$)/>"
    status = "200"
    target = "/index.html"
  }

  environment_variables = {
    REGION              = "${data.aws_region.current.id}"
    CODECOMMIT_REPO_ID  = "${var.create_codecommit_repo ? aws_codecommit_repository.codecommit_repo[0].repository_id : null}" //return null if no cc repo is created
    USER_POOL_ID        = "${aws_cognito_user_pool.user_pool.id}"
    IDENTITY_POOL_ID    = "${aws_cognito_identity_pool.identity_pool.id}"
    APP_CLIENT_ID       = "${aws_cognito_user_pool_client.user_pool_client.id}"
    GRAPHQL_ENDPOINT    = "${aws_appsync_graphql_api.appsync_graphql_api.uris.GRAPHQL}"
    GRAPHQL_API_ID      = "${aws_appsync_graphql_api.appsync_graphql_api.id}"
    LANDING_BUCKET_NAME = "${aws_s3_bucket.landing_bucket.id}"
  }
}

# resource "aws_amplify_domain_association" "example" {
#   count       = var.create_amplify_domain_association ? 1 : 0
#   app_id      = aws_amplify_app.app[0].id
#   domain_name = var.amplify_app_domain_name

#   # https://example.com
#   sub_domain {
#     branch_name = aws_amplify_branch.amplify_branch_main[0].branch_name
#     prefix      = ""
#   }

#   # https://www.example.com
#   sub_domain {
#     branch_name = aws_amplify_branch.amplify_branch_main[0].branch_name
#     prefix      = "www"
#   }
#   # https://dev.example.com
#   sub_domain {
#     branch_name = aws_amplify_branch.amplify_branch_dev[0].branch_name
#     prefix      = "dev"
#   }
#   # https://www.dev.example.com
#   sub_domain {
#     branch_name = aws_amplify_branch.amplify_branch_dev[0].branch_name
#     prefix      = "www.dev"
#   }
# }
