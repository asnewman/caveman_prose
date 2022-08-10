require "spec"
require "../src/game"

dummyPlayers = [
    Base_Player.new("Alpha", Teams::Glad),
    Base_Player.new("Bravo", Teams::Glad),
    Base_Player.new("Charlie", Teams::Glad),
    Base_Player.new("Delta", Teams::Mad),
    Base_Player.new("Echo", Teams::Mad),
]

describe "Game" do
  it "draws card properly" do
    game = Game.new [{"hand", "handcuff"}, {"dog", "dog walk"}], 60, dummyPlayers
    game.draw_new_card
    game.drawn_cards.size.should eq(1)
    game.deck.size.should eq(1)
    dummyPlayers[0].last_message.should_not eq("")
  end

  it "doesn't draws card if round has ended" do
    game = Game.new [{"hand", "handcuff"}, {"dog", "dog walk"}], 1, dummyPlayers
    game.draw_new_card
    sleep 2.seconds
    game.draw_new_card.should eq(nil)
  end

  it "starts round correctly" do
    game = Game.new [{"hand", "handcuff"}, {"dog", "dog walk"}], 60, dummyPlayers
    game.next_round
    game.curr_team.should eq(Teams::Mad)
  end

  it "adds and minuses correctly" do
    game = Game.new [{"hand", "handcuff"}, {"dog", "dog walk"}], 60, dummyPlayers

    game.add_three
    game.add_one
    game.scores[Teams::Glad].should eq(4)
    game.scores[Teams::Mad].should eq(0)

    game.next_round
    game.minus_one
    game.scores[Teams::Glad].should eq(4)
    game.scores[Teams::Mad].should eq(-1)
  end

  it "switches between players correctly" do
    game = Game.new [{"hand", "handcuff"}, {"dog", "dog walk"}], 60, dummyPlayers
    game.next_round
    game.next_round
    game.draw_new_card
    dummyPlayers[1].last_message.should_not eq("")
    game.next_round
    game.next_round
    game.next_round
    game.draw_new_card
    dummyPlayers[3].last_message.should_not eq("")
  end
end
