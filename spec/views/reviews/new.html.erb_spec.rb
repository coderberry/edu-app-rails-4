require 'spec_helper'

describe "reviews/new" do
  before(:each) do
    assign(:review, stub_model(Review,
      :membership => nil,
      :user => nil,
      :rating => 1,
      :comments => "MyText",
      :lti_app => nil
    ).as_new_record)
  end

  it "renders new review form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", reviews_path, "post" do
      assert_select "input#review_membership[name=?]", "review[membership]"
      assert_select "input#review_user[name=?]", "review[user]"
      assert_select "input#review_rating[name=?]", "review[rating]"
      assert_select "textarea#review_comments[name=?]", "review[comments]"
      assert_select "input#review_lti_app[name=?]", "review[lti_app]"
    end
  end
end
