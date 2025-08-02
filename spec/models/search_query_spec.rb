require 'rails_helper'

RSpec.describe SearchQuery, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:query) }

  describe ".trending" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    before do
      create_list(:search_query, 2, query: "rails", user: user1)
      create(:search_query, query: "rails", user: user2)
      create(:search_query, query: "ruby", user: user1)
    end

    it "returns queries with trending scores" do
      trending = SearchQuery.trending
      expect(trending.first).to respond_to(:query)
      expect(trending.first).to respond_to(:total_count)
      expect(trending.first.total_count).to be_a(Integer)
    end
  end

  describe ".total_searches" do
    it "returns the total number of search queries" do
      create_list(:search_query, 3)
      expect(SearchQuery.total_searches).to eq(3)
    end
  end

  describe ".total_unique_queries" do
    it "counts unique queries" do
      create(:search_query, query: "rails")
      create(:search_query, query: "rails")
      create(:search_query, query: "ruby")
      expect(SearchQuery.total_unique_queries).to eq(2)
    end
  end

  describe ".recent_searches" do
    it "returns limited recent searches" do
      old_query = create(:search_query, created_at: 2.days.ago)
      new_query = create(:search_query)
      results = SearchQuery.recent_searches
      expect(results).to include(new_query)
      expect(results).not_to include(old_query)
    end
  end
end
