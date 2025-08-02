# spec/controllers/analytics_controller_spec.rb

require 'rails_helper'

RSpec.describe AnalyticsController, type: :controller do
  before do
    # This line is now a better way to set the request's IP
    request.env['REMOTE_ADDR'] = "1.2.3.4"

    # Set up user with a known IP
    user = create(:user, ip: "1.2.3.4")
    create_list(:search_query, 3, user: user)
  end

  describe "GET #index" do
    it "assigns analytics variables" do
      get :index

      expect(assigns(:total_searches)).to eq(3)
      expect(assigns(:total_unique_queries)).to eq(3)
      expect(assigns(:recent_searches)).to be_present
      expect(assigns(:top_queries)).to be_an(ActiveRecord::Relation)
    end
  end
end
