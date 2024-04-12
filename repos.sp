dashboard "Repos" {

  tags = {
    service = "Hacker News"
  }

container {
    
    text {
      width = 8
      value = replace(
        replace(
          "${local.menu}",
          "__HOST__",
          "${local.host}"
        ),
        "[Repos](${local.host}/hackernews.dashboard.Repos)",
        "Repos"
      )
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