require 'spec_helper'

describe GraphController do

  describe "GET 'graph_paint'" do
    it "returns http success" do
      get 'graph_paint'
      response.should be_success
    end
  end

  describe "GET 'graph_settings'" do
    it "returns http success" do
      get 'graph_settings'
      response.should be_success
    end
  end

end
