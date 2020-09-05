namespace :db do
  desc 'create ShowReview of view'
  task create_view: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      create view show_reviews as
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
    SQL
  end
  task drop_view: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      drop view show_reviews;
    SQL
  end
end
