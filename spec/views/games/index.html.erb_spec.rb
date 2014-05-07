require 'spec_helper'

describe "games/index" do
  before(:each) do
    assign(:games, [
      stub_model(Game,
        :pgn => "Pgn",
        :status => "Status"
      ),
      stub_model(Game,
        :pgn => "Pgn",
        :status => "Status"
      )
    ])
  end

  it "renders a list of games" do
    render
    assert_select "tr>td", :text => "Pgn".to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
  end
end
