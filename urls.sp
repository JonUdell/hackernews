dashboard "Urls" {

  tags = {
    service = "Hacker News"
  }

  container {
    
    text {
      width = 6
      value = <<EOT
[Home](${local.host}/hackernews.dashboard.Home)
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
Urls
      EOT
    }

  }

  container {

    table  {
      width = 8
      query = query.urls
      column "url" {
        wrap = "all"
      }
    }

    container {
      width = 4

      chart  {
        title = "domains by count"    
        type = "donut"
        sql = <<EOQ
          select 
            substring(url from 'http[s]*://([^/$]+)') as domain,
            count(*)
          from
            hn_items_all
          where
            url != ''
          group by
            domain
          order by 
            count desc
          limit
            15
        EOQ
      }

      chart  {
        title = "domains by max score"    
        type = "donut"
        sql = <<EOQ
          select 
            substring(url from 'http[s]*://([^/$]+)') as domain,
            max(score::int) as "max score"
          from
            hn_items_all
          where
            url != ''
          group by
            domain
          order by 
            "max score" desc
          limit
            15
        EOQ
      }


    }

  }

}