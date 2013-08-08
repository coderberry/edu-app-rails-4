require 'spec_helper'

describe "tags/new" do
  before(:each) do
    assign(:tag, stub_model(Tag,
      :short_name => "MyString",
      :name => "MyString",
      :context => "MyString"
    ).as_new_record)
  end

  it "renders new tag form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", tags_path, "post" do
      assert_select "input#tag_short_name[name=?]", "tag[short_name]"
      assert_select "input#tag_name[name=?]", "tag[name]"
      assert_select "input#tag_context[name=?]", "tag[context]"
    end
  end
end
