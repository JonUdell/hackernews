dashboard "Posts" {

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
        "[Posts](${local.host}/hackernews.dashboard.Posts)",
        "Posts"
      )
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
