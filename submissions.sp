dashboard "Submissions" {

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
[Repos](${local.host}/hackernews.dashboard.Repos)
🞄
[Search](${local.host}/hackernews.dashboard.Search)
🞄
[Sources](${local.host}/hackernews.dashboard.Sources)
🞄
Submissions
🞄
[Urls](${local.host}/hackernews.dashboard.Urls)
      EOT
    }

  }


  container {
    width = 8

    input "hn_user" {
      width = 6
      placeholder = "search or choose user"
      title = "hn user"
      type = "select"
      sql = <<EOQ
        select distinct
          h.by as label,
          h.by as value
        from
          hn_items_all h
        order by
          by
      EOQ    
    }

  }

  container {

    table  {
      width = 8
      args = [
        self.input.hn_user.value
      ]
      query = query.submission_times
      column "id" {
        href = "https://news.ycombinator.com/item?id={{.'id'}}"
      }
      column "title" {
        wrap = "all"
      }
      column "url" {
        wrap = "all"
      }
    }
  
    chart  {
      width = 4
      type = "bar"
      args = [
        self.input.hn_user.value
      ]
      axes {
        x {
          title {
            value = "submissions"
          }
        }
        y {
          title {
            value = "day"
          }
        }
      }
      query = query.submission_days
    }

  }
 

}