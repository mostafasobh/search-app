class SearchQuery < ApplicationRecord
  belongs_to :user

  validates :query, presence: true

  # Scope for recent queries (e.g. last 24h)
  scope :recent, ->(since = 24.hours.ago) { where("created_at >= ?", since) }
  scope :total_searches, -> { all }  # just use `.count` when needed
  scope :total_unique_queries, -> { select(:query).distinct }
  scope :recent_searches, ->(limit = 10) { where("created_at >= ?", 2.days.ago).order(created_at: :desc).limit(limit) }

  def self.trending(limit = 10, since = 24.hours.ago)
    select("query,
            COUNT(*) as total_count,
            COUNT(DISTINCT user_id) as unique_users,
            MAX(created_at) as last_time")
      .where("created_at >= ?", since)
      .group(:query)
      .order(Arel.sql("
        LOG(COUNT(*) + 1) *
        (COUNT(DISTINCT user_id) + 1) *
        (1 + 0.1 * LENGTH(query)) *
        CASE WHEN NOW() - MAX(created_at) < INTERVAL '2 hours' THEN 1.5 ELSE 1 END /
        POWER(GREATEST(EXTRACT(EPOCH FROM (NOW() - MAX(created_at)))/3600, 1), 0.8)
      DESC"))
      .limit(limit)
  end
end
