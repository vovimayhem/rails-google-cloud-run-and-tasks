require 'rails_helper'

RSpec.describe "Sessions", type: :request do

  describe "GET /sign-in" do
    it "returns http success" do
      get "/sessions/sign-in"
      expect(response).to have_http_status(:success)
    end
  end

end
