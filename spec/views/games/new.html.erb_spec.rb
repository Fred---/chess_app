require 'spec_helper'

describe "games/new" do
  before(:each) do
    assign(:game, stub_model(Game,
      :pgn => "MyString",
      :status => "MyString"
    ).as_new_record)
  end

  it "renders new game form" do
    render

    assert_select "form[action=?][method=?]", games_path, "post" do
      assert_select "input#game_pgn[name=?]", "game[pgn]"
      assert_select "input#game_status[name=?]", "game[status]"
    end
  end
end
