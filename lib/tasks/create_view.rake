namespace :db do
  desc 'create ShowReview of view'
  task create_view: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      create view join_reviews as
      select posts.id as post_id, review.id as review_id, review.body as review_body, review.created_at as review_created_at, review.thrown_coins as review_thrown_coins,
      review.user_id as reviewer_id, reviewer.name as reviewer_name, reviewer.nickname as reviewer_nickname, reviewer.icon as reviewer_icon,
      response.id as response_id, response.body as response_body, response.created_at as response_created_at, response.thrown_coins as response_thrown_coins,
      response.user_id as responder_id, responder.name as responder_name, responder.nickname as responder_nickname, responder.icon as responder_icon
      from
      	posts
      left outer join
      	reviews as review
      	on review.post_id = posts.id
      left outer join
      	users as reviewer
      	on reviewer.id = review.user_id
      left outer join
      	review_links
      	on review.id = review_links.from
      left outer join
      	reviews as response
      	on response.id = review_links.to
      left outer join
      	users as responder
      	on responder.id = response.user_id
      where review.primary = true
      order by review.created_at, response.created_at;

      create view show_reviews as
      select post_id, review_id, review_body, review_created_at, review_thrown_coins,
      reviewer_id, reviewer_name, reviewer_nickname, reviewer_icon,
      response_id, response_body, response_created_at, response_thrown_coins,
      responder_id, responder_name, responder_nickname, responder_icon
      from(select * from join_reviews union
      select join_reviews.post_id,
        join_reviews.review_id, join_reviews.review_body,
        join_reviews.review_created_at, join_reviews.review_thrown_coins,
        join_reviews.reviewer_id, join_reviews.reviewer_name,
        join_reviews.reviewer_nickname, join_reviews.reviewer_icon,
        null as response_id, null as response_body, null as response_created_at,
        null as response_thrown_coins, null as responder_id, null as responder_name,
        null as responder_nickname, null as responder_icon
      from join_reviews
      where join_reviews.response_id is not null) as result
      order by result.review_created_at, result.response_created_at nulls first;
    SQL
  end
  task drop_view: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      drop view show_reviews;
      drop view join_reviews;
    SQL
  end
end
