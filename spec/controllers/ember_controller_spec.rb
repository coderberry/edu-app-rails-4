require 'spec_helper'

describe EmberController do

  describe "GET 'app_list'" do
    it "returns http success" do
      get 'app_list'
      response.should be_success
    end
  end

end
