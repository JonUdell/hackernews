dashboard "People" {

  tags = {
    service = "Hacker News"
  }

  container {
    
    text {
      width = 6
      value = <<EOT
[Home](${local.host}/hackernews.dashboard.Home)
🞄
People
🞄
[Posts](${local.host}/hackernews.dashboard.Posts)
🞄
[Repos](${local.host}/hackernews.dashboard.Repos)
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

  table {
    title = "hacker news people with max score > 200"
    sql = "select * from hn_people order by karma::int desc"
    column "by" {
    href = "${local.host}/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
    }
    column "twitter_user" {
    href = "https://twitter.com/{{.'twitter'}}"
    }
    column "github_user" {
    href = "https://github.com/{{.'github'}}"
    }
  }

}