class SearchController < ApplicationController
  def index; end

  def suggestions
    query = params[:query].to_s.downcase.strip
    return render json: [] if query.blank?

    suggestions = @user.search_queries
                      .where("query LIKE ?", "%#{query}%")
                      .distinct
                      .limit(7)
                      .pluck(:query)

    render json: suggestions
  end

  def log_query
    query = params[:query].to_s.downcase.strip
    return head :bad_request if query.blank?

    query = @user.search_queries.new(query: query)
    unless query.save
      return head :internal_server_error
    end

    head :ok
  end
end
