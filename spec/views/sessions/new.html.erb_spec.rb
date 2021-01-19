require 'rails_helper'

RSpec.describe "sessions/new", type: :view do
  before(:each) do
    assign(:session, Session.new(
      email: "MyString",
      password: "MyString",
      token: "MyString"
    ))
  end

  it "renders new session form" do
    render

    assert_select "form[action=?][method=?]", sessions_path, "post" do

      assert_select "input[name=?]", "session[email]"

      assert_select "input[name=?]", "session[password]"

      assert_select "input[name=?]", "session[token]"
    end
  end
end
