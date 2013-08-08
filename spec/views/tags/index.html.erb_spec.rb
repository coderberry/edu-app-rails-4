require 'spec_helper'

describe "tags/index" do
  before(:each) do
    assign(:tags, [
      stub_model(Tag,
        :short_name => "Short Name",
        :name => "Name",
        :context => "Context"
      ),
      stub_model(Tag,
        :short_name => "Short Name",
        :name => "Name",
        :context => "Context"
      )
    ])
  end

  it "renders a list of tags" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Short Name".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Context".to_s, :count => 2
  end
end
