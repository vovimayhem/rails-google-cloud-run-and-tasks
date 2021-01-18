require 'rails_helper'

RSpec.describe "sessions/edit", type: :view do
  before(:each) do
    @session = assign(:session, Session.create!(
      email: "MyString",
      password: "MyString",
      token: "MyString"
    ))
  end

  it "renders the edit session form" do
    render

    assert_select "form[action=?][method=?]", session_path(@session), "post" do

      assert_select "input[name=?]", "session[email]"

      assert_select "input[name=?]", "session[password]"

      assert_select "input[name=?]", "session[token]"
    end
  end
end
