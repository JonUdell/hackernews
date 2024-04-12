dashboard "Search" {

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
        "[Search](${local.host}/hackernews.dashboard.Search)",
        "Search"
      )
    }

  }  

  container  {

    input "search_term" {
      width = 4
      placeholder = "search_term (matches in urls or titles, can be regex)"
      type = "text"
    }

    text "search_examples" {
      width = 8
      value = <<EOT
Examples: 
[gpt](${local.host}/hackernews.dashboard.Search?input.search_term=gpt),
[go.+generic](${local.host}/hackernews.dashboard.Search?input.search_term=%20go.%2bgeneric),
[simonwillison](${local.host}/hackernews.dashboard.Search?input.search_term=simonwillison)
[github.com/microsoft](${local.host}/hackernews.dashboard.Search?input.search_term=github.com%2Fmicrosoft), 
[github.com.+sqlite](${local.host}/hackernews.dashboard.Search?input.search_term=github.com.%2bsqlite),
[nytimes.+/technology](${local.host}/hackernews.dashboard.Search?input.search_term=nytimes.%2b/technology)
      EOT
    }

  }


    table {
      args = [
        self.input.search_term
      ]
      sql = <<EOQ
        select
          id,
          by,
          title,
          to_char(time::timestamptz, 'YYYY-MM-DD hHH24') as time,
          case 
            when url is null then ''
            else url
          end as url,
          score,
          descendants as comments
        from 
          hn
        where
           title ~* $1 or url ~* $1
        order by
          score::int desc
      EOQ
      column "url" {
        wrap = "all"
      }
      column "id" {
        href = "https://news.ycombinator.com/item?id={{.'id'}}"
      }
      column "by" {
        href = "${local.host}/hackernews.dashboard.Submissions?input.hn_user={{.'by'}}"
      }

  }

}