dashboard "Home" {

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
        "[Home](${local.host}/hackernews.dashboard.Home)",
        "Home"
      )
    }

  }  

  container {

    card {
      width = 2
      sql = <<EOQ
        select count(*) as stories from hn
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select count(*) as "ask hn" from hn where title ~ '^Ask HN'
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select count(*) as "show hn" from hn where title ~ '^Show HN'
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select
          count( distinct( to_char( time::timestamptz, 'YYYY-MM-DD' ) ) ) as days
        from
          hn
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select to_char(min(time::timestamptz), 'YYYY-MM-DD hHH24') as "oldest" from hn
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select to_char(max(time::timestamptz), 'YYYY-MM-DD hHH24') as "newest" from hn
      EOQ
    }
  }

  container {

    card {
      width = 3
      sql = <<EOQ
        select max(score::int) as "max score" from hn
      EOQ
    }
    
    card {
      width = 3
      sql = <<EOQ
        select round(avg(score::int), 1) as "avg score" from hn

      EOQ
    }

    card {
      width = 3
      sql = <<EOQ
        select round(avg(score::int), 1) as "avg ask score" from hn where title ~ '^Ask HN'
      EOQ
    }

    card {
      width = 3
      sql = <<EOQ
        select round(avg(score::int), 1) as "avg show score" from hn where title ~ '^Show HN'
      EOQ
    }

  }

  container {

    chart {
      base = chart.companies_base
      width = 4
      type = "donut"
      title = "company mentions: last 24 hours"
      query = query.mentions
      args = [ local.companies, 1440, 0 ]
    }

    chart {
      base = chart.companies_base
      width = 4
      type = "donut"
      title = "company mentions: last 7 days"
      query = query.mentions
      args = [ local.companies, 10080, 0 ]
    }

    chart {
      base = chart.companies_base
      width = 4
      type = "donut"
      title = "company mentions: last 30 days"
      query = query.mentions
      args = [ local.companies, 43200, 0 ] 
    }

  }

  container {

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "language mentions: last 24 hours"
      query = query.mentions
      args = [ local.languages, 1440, 0 ]
    }

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "language mentions: last 7 days"
      query = query.mentions
      args = [ local.languages, 10080, 0 ]
    }

    chart {
      base = chart.languages_base
      width = 4
      type = "donut"
      title = "language mentions: last 30 days"
      query = query.mentions
      args = [ local.languages, 43200, 0 ]
    }

  }

  container {

    chart {
      base = chart.os_base
      width = 4
      type = "donut"
      title = "os mentions: last 24 hours"
      query = query.mentions
      args = [ local.operating_systems, 1440, 0 ]
    }

    chart { 
      base = chart.os_base
      width = 4
      type = "donut"
      title = "os mentions: last 7 days"
      query = query.mentions
      args = [ local.operating_systems, 10080, 0 ]
    }

    chart {
      base = chart.os_base
      width = 4
      type = "donut"
      title = "os mentions: last 30 days"
      query = query.mentions
      args = [ local.operating_systems, 43200, 0 ]
    }

  }

  container {

    chart {
      base = chart.cloud_base
      width = 4
      type = "donut"
      title = "cloud mentions: last 24 hours"
      query = query.mentions
      args = [ local.clouds, 1440, 0 ]
    }

    chart {
      base = chart.cloud_base
      width = 4
      type = "donut"
      title = "cloud mentions: last 7 days"
      query = query.mentions
      args = [ local.clouds, 10080, 0 ]
    }

    chart {
      base = chart.cloud_base
      width = 4
      type = "donut"
      title = "cloud mentions: last 30 days"
      query = query.mentions
      args = [ local.clouds, 43200, 0 ] 
    }

  }

  container {

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "db mentions: last 24 hours"
      query = query.mentions
      args = [ local.dbs, 1440, 0 ]
    }

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "db mentions: last 7 days"
      query = query.mentions
      args = [ local.dbs, 10080, 0 ]
    }

    chart {
      base = chart.db_base
      width = 4
      type = "donut"
      title = "db mentions: last 30 days"
      query = query.mentions
      args = [ local.dbs, 43200, 0 ] 
    }

  }

  container {

    chart {
      base = chart.editor_base
      width = 4
      type = "donut"
      title = "editor mentions: last 24 hours"
      query = query.mentions
      args = [ local.editors, 1440, 0 ]
    }

    chart {
      base = chart.editor_base
      width = 4
      type = "donut"
      title = "editor mentions: last 7 days"
      query = query.mentions
      args = [ local.editors, 10080, 0 ]
    }

    chart {
      base = chart.editor_base
      width = 4
      type = "donut"
      title = "editor mentions: last 30 days"
      query = query.mentions
      args = [ local.editors, 43200, 0 ] 
    }

  }    


  container {

    chart {
      width = 6
      title = "stories by hour: last 10 days"
      query = query.stories_by_hour
    }
    chart {
      width = 6
      title = "ask and show by day: last 30 days"
      query = query.ask_and_show_by_day
    }

  }  

  container {
    width = 12
    
    chart {
      title = "users by total score: last 7 days"
          width = 6
      sql = <<EOQ
        select
          by,
          sum(score) as sum_score
        from
          hn
        where
          time >= now() - interval '7 days'
        group by 
          by
        order by
          sum_score desc
        limit 
          15
      EOQ
    }
    
    chart {
      title = "users by total comments: last 7 days"
      width = 6
      sql = <<EOQ
        select
          by,
          sum(descendants) as comments
        from
          hn
        where
          time >= now() - interval '7 days'
          and descendants > 0
        group by
          by,
          descendants
        order by
          descendants desc
        limit
          15
      EOQ
    }

  }


}

