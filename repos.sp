dashboard "Repos" {

  tags = {
    service = "Hacker News"
  }

  container {
    
    text {
      width = 6
      value = <<EOT
[Home](${local.host}/hackernews.dashboard.Home)
🞄
[People](${local.host}/hackernews.dashboard.People)
🞄
[Posts](${local.host}/hackernews.dashboard.Posts)
🞄
Repos
🞄
[Search](${local.host}/hackernews.dashboard.Search)
🞄
[Sources](${local.host}/hackernews.dashboard.Sources)
🞄
[Submissions](${local.host}/hackernews.dashboard.Submissions?input.hn_user=none)
🞄
[Urls](${local.host}/hackernews.dashboard.Urls)
      EOT
    } 
  } 


  container  {

    table {
      width = 8
      title = "company repos: last 30 days"
      query = query.repos_by_company
      args = [ local.companies ]
      column "by" {
        href = "${local.host}/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
      }
      column "url" {
        wrap = "all"
      }
    }

    chart {
      width = 4
      type = "donut"
      title = "company repos: last 30 days"
      query = query.repo_counts_by_company
      args = [ local.companies ]

    }


  }

}