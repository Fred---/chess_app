require 'spec_helper'

describe "games/show" do
  before(:each) do
    @game = assign(:game, stub_model(Game,
      :pgn => "Pgn",
      :status => "Status"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Pgn/)
    expect(rendered).to match(/Status/)
  end
end
