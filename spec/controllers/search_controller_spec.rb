RSpec.describe SearchController, type: :controller do
  let(:user) { create(:user, ip: "1.2.3.4") }

  before do
    request.env['REMOTE_ADDR'] = user.ip
  end

  describe "GET #suggestions" do
    it "returns empty array if query is blank" do
      get :suggestions, params: { query: "" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("[]")
    end

    it "returns matching suggestions from user search queries" do
      create(:search_query, user: user, query: "rails")
      create(:search_query, user: user, query: "ruby")
      create(:search_query, user: user, query: "javascript")

      get :suggestions, params: { query: "ra" }
      json = JSON.parse(response.body)
      expect(json).to include("rails")
      expect(json).not_to include("ruby", "javascript")
    end

    it "limits the number of suggestions to 7" do
      10.times { |i| create(:search_query, user: user, query: "query#{i}") }

      get :suggestions, params: { query: "query" }
      json = JSON.parse(response.body)
      expect(json.size).to be <= 7
    end
  end

  describe "POST #log_query" do
    it "returns bad_request if query is blank" do
      post :log_query, params: { query: "" }
      expect(response).to have_http_status(:bad_request)
    end

    it "returns ok if query is saved" do
      post :log_query, params: { query: "rails" }
      expect(response).to have_http_status(:ok)
    end

    it "returns internal_server_error if saving fails" do
      allow_any_instance_of(SearchQuery).to receive(:save).and_return(false)

      post :log_query, params: { query: "rails" }
      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
