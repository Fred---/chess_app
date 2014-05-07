require 'spec_helper'

describe "Games" do
  describe "GET /games" do
    it "works! (now write some real specs)" do
      get games_path
      expect(response.status).to be(200)
    end
  end
end
