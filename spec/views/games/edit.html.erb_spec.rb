require 'spec_helper'

describe "games/edit" do
  before(:each) do
    @game = assign(:game, stub_model(Game,
      :pgn => "MyString",
      :status => "MyString"
    ))
  end

  it "renders the edit game form" do
    render

    assert_select "form[action=?][method=?]", game_path(@game), "post" do
      assert_select "input#game_pgn[name=?]", "game[pgn]"
      assert_select "input#game_status[name=?]", "game[status]"
    end
  end
end
