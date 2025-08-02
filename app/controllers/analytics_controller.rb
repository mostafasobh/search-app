class AnalyticsController < ApplicationController
  def index
    @total_searches = @user.search_queries.total_searches.count
    @total_unique_queries = @user.search_queries.total_unique_queries.count
    @recent_searches = @user.search_queries.recent_searches
    @top_queries = @user.search_queries.trending
  end
end
