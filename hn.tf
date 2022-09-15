terraform {
  required_providers {
    steampipecloud = {
      source = "turbot/steampipecloud"
    }
  }
}

resource "steampipecloud_workspace_mod" "steampipe_stats" {
  organization = "acme" 
  workspace_handle = "jon"
  path = "github.com/judell/hackernews"
  constraint = "v0.3"
}
