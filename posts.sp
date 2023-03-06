dashboard "Posts" {

  tags = {
    service = "Hacker News"
  }

  container {
    
    text {
      width = 6
      value = <<EOT
[Home](${local.host}/hackernews.dashboard.Home)
🞄
Posts
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

  container {

    table {
      title = "top-rated posts"
      query = query.posts
      column "link" {
        href = "https://news.ycombinator.com/item?id={{.'link'}}"
      }
      column "title" {
        wrap = "all"
      }
      column "by" {
        href = "${local.host}/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
      }
      column "url" {
        wrap = "all"
      }
      column "domain" {
        href = "${local.host}/hackernews.dashboard.Search?input.search_term={{.'domain'}}"
      }

    }

  }

}
