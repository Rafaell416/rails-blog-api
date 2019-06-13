class PostSearchService
  def self.search(current_posts, query)
    current_posts.where("title like '%#{query}%'")
  end
end