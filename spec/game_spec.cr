require "spec"
require "../src/game"

dummy_players = [] of Base_Player

Spec.before_each do
  dummy_players = [
    Base_Player.new("Alpha", Teams::Glad),
    Base_Player.new("Bravo", Teams::Glad),
    Base_Player.new("Charlie", Teams::Glad),
    Base_Player.new("Delta", Teams::Mad),
    Base_Player.new("Echo", Teams::Mad),
  ]
end

describe "Game" do
  it "draws card properly" do
    game = Game.new [{"hand", "handcuff"}, {"dog", "dog walk"}], 60, dummy_players
    game.draw_new_card
    game.drawn_cards.size.should eq(1)
    game.deck.size.should eq(1)
    dummy_players[0].messages[1].should_not eq("")
  end

  it "doesn't draws card if round has ended" do
    game = Game.new [{"hand", "handcuff"}, {"dog", "dog walk"}], 1, dummy_players
    game.draw_new_card
    sleep 3.seconds
    game.draw_new_card.should eq(nil)
  end

  it "starts round correctly" do
    game = Game.new [{"hand", "handcuff"}, {"dog", "dog walk"}], 60, dummy_players
    game.next_round
    game.curr_team.should eq(Teams::Mad)
  end

  it "adds and minuses correctly" do
    game = Game.new [{"hand", "handcuff"}, {"dog", "dog walk"}], 60, dummy_players

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
    game = Game.new [{"hand", "handcuff"}, {"dog", "dog walk"}], 60, dummy_players
    game.next_round
    game.next_round
    game.draw_new_card
    dummy_players[1].messages[0].should eq("Game started")
    dummy_players[1].messages[1].should eq("Round start")
    dummy_players[1].messages[2].should eq("Round start")
    dummy_players[1].messages[3].should_not eq("")
    game.next_round
    game.next_round
    game.next_round
    game.draw_new_card
    dummy_players[3].messages[0].should eq("Game started")
    dummy_players[3].messages[1].should eq("Round start")
    dummy_players[3].messages[2].should eq("Round start")
    dummy_players[3].messages[3].should eq("Round start")
    dummy_players[3].messages[4].should eq("Round start")
    dummy_players[3].messages[5].should eq("Round start")
    dummy_players[3].messages[6].should_not eq("")
  end

  it "messages game start to all players" do
    game = Game.new [{"hand", "handcuff"}, {"dog", "dog walk"}], 60, dummy_players
    dummy_players.each do |player|
      player.messages[0].should eq("Game started")
    end
  end
end
