query "repos_by_company" {
  sql = <<EOQ
    with names as (
      select
        unnest( $1::text[] ) as name
    ),
    hn_items as (
      select
        (regexp_match(url, 'github.com/(\w+)'))[1] as name,
        by,
        score::int,
        descendants::int as comments,
        url
      from
        hn
      where
        url ~* 'github.com/'
    )
    select 
      h.*
    from 
      hn_items h 
    join 
      names n 
    on 
      h.url ~ ('github.com/' || lower(n.name) || '/')
    order by
      h.name
  EOQ
  param "names" {}
}

query "repo_counts_by_company" {
  sql = <<EOQ
    with names as (
      select
        unnest( $1::text[] ) as name
    ),
    hn_items as (
      select
        (regexp_match(url, 'github.com/(\w+)'))[1] as name,
        by,
        score::int,
        descendants::int as comments,
        url
      from
        hn
      where
        url ~* 'github.com/'
    )
    select 
      h.name,
      count(*)
    from 
      hn_items h 
    join 
      names n 
    on 
      h.url ~ ('github.com/' || lower(n.name) || '/')
    group by
      h.name
    order by
      count desc
  EOQ
  param "names" {}
}


query "mentions" {
  sql = <<EOQ
    with names as (
      select
        unnest( $1::text[] ) as name
    ),
    counts as (
      select
        name,
        (
          select
            count(*)
          from
            hn
          where
            title ~* name
            and (extract(epoch from now() - time::timestamptz) / 60)::int between symmetric $2 and $3
        ) as mentions
        from
          names
    )
    select
      replace(name, '\', '') as name,
      mentions
    from
      counts
    where
      mentions > 0
    order by 
      mentions desc
  EOQ
  param "names" {}
  param "min_minutes_ago" {}
  param "max_minutes_ago" {}
}

query "submission_times" {
  sql = <<EOQ
    select
      id,
      to_char(time::timestamptz, 'YYYY-MM-DD hHH24') as time,
      title,
      url,
      score,
      case
        when descendants is null then 0
        else descendants
      end as comments
    from 
      hn
    where
      by = $1
    order by
      score::int desc
  EOQ
  param "hn_user" {}

}

query "submission_days" {
  sql = <<EOQ
    select
      to_char(time::timestamptz, 'YY-MM-DD') as day,
      count(to_char(time::timestamptz, 'YY-MM-DD'))
    from 
      hn
    where
      by = $1
    group by 
      day
    order by
      day desc
  EOQ
  param "hn_user" {}
}

query "domains" {
  sql = <<EOQ
    with domains as (
      select
        url,
        substring(url from 'http[s]*://([^/$]+)') as domain
    from 
      hn
    where
      url is not null
    ),
    avg_and_max as (
      select
        substring(url from 'http[s]*://([^/$]+)') as domain,
        max(score::int) as max_score
      from
        hn
      group by
        substring(url from 'http[s]*://([^/$]+)')
    ),
    counted as (
      select 
        domain,
        count(*)
      from 
        domains
      group by
        domain
      order by
        count desc
    )
    select
      a.domain,
      c.count,
      a.max_score
    from
      avg_and_max a
    join
      counted c 
    using 
      (domain)
    where
      c.count > 5
    order by
      max_score desc
  EOQ
}

query "domain_detail" {
  sql = <<EOQ
    with items_by_day as (
      select
        to_char(time::timestamptz, 'YYYY-MM-DD') as day,
        substring(url from 'http[s]*://([^/$]+)') as domain
    from 
      hn
    where
      substring(url from 'http[s]*://([^/$]+)') = $1
    )
    select 
      day,
      count(*)
    from 
      items_by_day
    group by
      day
    order by
      day
  EOQ
  param "domain" {}
}

query "source_detail" {
  sql = <<EOQ
    select
      h.id as link,
      to_char(h.time::timestamptz, 'YYYY-MM-DD hHH24') as time,
      h.score,
      h.title,
      h.url
    from
      hn h
    where 
      h.url ~ $1
    order by
      h.score::int desc
  EOQ
  param "source_domain" {}
}

query "people" {
  sql = <<EOQ
    with hn_users_and_max_scores as (
      select 
        by,
        max(score::int) as max_score
      from
        hn
      group by
        by
      having
        max(score::int) > 200
    ),
    hn_info as (
      select 
        h.by,
        h.max_score,
        ( select count(*) from hn where by = h.by ) as stories,
        ( select sum(descendants::int) from hn where descendants is not null and by = h.by group by h.by ) as comments
      from 
        hn_users_and_max_scores h
      where
        h.by != 'aiobe' -- causes "resource not accessible by integration" in gh actions, no idea why
    ),
    plus_gh_info as (
      select
        h.*,
        g.html_url as github_url,
        case 
          when g.name is null then ''
          else g.name
        end as gh_name,
        g.followers::int as gh_followers,
        g.twitter_username,
        g.public_repos
      from
        hn_info h
      left join
        github_user g
      on 
        h.by = g.login
      order by
        h.by
    ) 
    select
      p.by,
      u.karma,
      p.max_score,
      p.stories,
      p.comments,
      p.github_url,
      p.gh_name,
      p.public_repos,
      p.gh_followers,
      case 
        when p.twitter_username is null then ''
        else 'https://twitter.com/' || p.twitter_username
      end as twitter_url
    from
      plus_gh_info p 
    join
      hackernews_user u 
    on 
      p.by = u.id
    order by
      karma desc
   EOQ
}

query "posts" {
  sql = <<EOQ
    with data as (
      select 
        id as link,
        to_char(time::timestamptz, 'YYYY-MM-DD hHH24') as time,
        title,
        by,
        score::int,
        descendants::int as comments,
        url,
        case
          when url = '' then ''
          else substring(url from 'http[s]*://([^/$]+)')
        end as domain
      from
        hn
      where 
        score != 0
        and descendants != 0
      order by 
        score desc
      limit 200
    )
    select
      *
    from
      data
    order by
      time desc
  EOQ
}

query "urls" {
  sql = <<EOQ
    select
      url,
      to_char(time::timestamptz, 'YYYY-MM-DD hHH24') as time,
      sum(score::int) as score,
      sum(descendants::int) as comments
    from
      hn
    where
      url != ''
    group by
      url,
      time,
      score
    order by
      score desc
    limit 
      500
  EOQ
}

query "stories_by_hour" {
  sql = <<EOQ
    with data as (
      select
        time::timestamptz
      from
        hn
      where
        time::timestamptz > now() - interval '10 day'
    ),
    by_hour as (
      select
        to_char(time,'MM-DD hHH24') as month_hour,
        count(*)
      from 
        data
      group by
        month_hour
    )
    select
      month_hour,
      count
    from
      by_hour
    order by
      month_hour
  EOQ
}

query "ask_and_show_by_day" {
  sql = <<EOQ
    with ask_hn as (
      select
        date(time) as day,
        count(*) as ask_count
      from
        hn
      where
        time > now() - interval '30 day'
        and title ~ '^Ask HN'
      group by
        day
      order by
        day
    ),
    show_hn as (
      select
        date(time) as day,
        count(*) as show_count
      from
        hn
      where
        time > now() - interval '30 day'
        and title ~ '^Show HN'
      group by
        day
      order by
        day
    )
    select
      day,
      ask_count as "Ask HN",
      show_count as "Show HN"
    from 
      ask_hn a
    left join 
      show_hn s 
    using 
      (day)
  EOQ
}

query "create_scores_and_comments" {
  sql = <<EOQ
    create table hn_scores_and_comments as ( 
      select 
        id, 
        score, 
        descendants 
      from 
        hn 
      where 
        score::int > 5 
      order by
        time desc 
    )
  EOQ
}

query "new_scores_and_comments" {
  sql = <<EOQ
    create table new_sc as ( 
      with urls as ( 
        select 'https://hacker-news.firebaseio.com/v0/item/' || sc.id || '.json' as url
      from 
        hn_scores_and_comments sc 
      order by 
        url
      ), 
      new_sc as ( 
        select  
          response_body::jsonb->>'id' as id, 
          response_body::jsonb->>'score' as new_score, 
          response_body::jsonb->>'descendants' as new_descendants 
      from 
        net_http_request n 
      join 
        urls u 
      on 
        u.url = n.url
      )
      select 
        sc.id, 
        sc.score, 
        sc.descendants, 
        n.new_score, 
        n.new_descendants 
      from 
        new_sc n 
      join 
        hn_scores_and_comments sc 
      on
        n.id = sc.id
    )          
  EOQ
}

query "update_scores_and_comments" {
  sql = <<EOQ
    update 
      hn a 
    set 
      score = new_sc.new_score, 
      descendants = new_sc.new_descendants 
    from 
      csv.new_sc 
    where new_sc.id = a.id
  EOQ
}
