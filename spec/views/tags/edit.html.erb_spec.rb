require 'spec_helper'

describe "tags/edit" do
  before(:each) do
    @tag = assign(:tag, stub_model(Tag,
      :short_name => "MyString",
      :name => "MyString",
      :context => "MyString"
    ))
  end

  it "renders the edit tag form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", tag_path(@tag), "post" do
      assert_select "input#tag_short_name[name=?]", "tag[short_name]"
      assert_select "input#tag_name[name=?]", "tag[name]"
      assert_select "input#tag_context[name=?]", "tag[context]"
    end
  end
end
