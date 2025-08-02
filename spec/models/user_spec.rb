require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:ip) }
  it { should have_many(:search_queries).dependent(:destroy) }
end
