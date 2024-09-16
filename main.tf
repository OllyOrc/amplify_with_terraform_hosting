// This is a template file for a basic deployment.
// Modify the parameters below with actual values
module "sample-qs" {
  source = "./modules/sample-module"

  path_to_build_spec = "../amplify.yml"
  
  # - Amplify App -
# Connect Amplify to GitHub
existing_repo_url              = "https://github.com/OllyOrc/amplify_with_terraform_hosting"
lookup_ssm_github_access_token = true                                 // set to true if the resource exists in your AWS Account
ssm_github_access_token_name   = "github-access-token" // name of the parameter in SSM

cognito_groups = {
    Admin : {
      name        = "Admin"
      description = "Admin users"
    },
    Standard : {
      name        = "Standard"
      description = "Standard users"
    },

  }

  cognito_users = {
    # Admin Users to create
    OliverHaynes : {
      username         = "ohaynes"
      given_name       = "Oliver"
      family_name      = "Haynes"
      email            = "oliverhaynes@btinternet.com"
      email_verified   = true // no touchy
      group_membership = ["Admin", "Standard"]
    },

    # Standard Users to create
    Rome1 : {
      username         = "rome1"
      given_name       = "Rome"
      family_name      = "1"
      email            = "rome1@btinternet.com"
      email_verified   = true // no touchy
      group_membership = ["Standard"]
    }
  }

}
