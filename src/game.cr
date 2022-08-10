enum Teams
  Glad
  Mad
end

def print_card(curr_card)
  curr_card.each do |card|
    puts card
  end
end

alias Card = Tuple(String, String)

class Game
  @curr_team : Teams

  def initialize(@deck : Array(Card), @round_length : Int32, players : Array(Base_Player))
    @drawn_cards = [] of Card
    @curr_team = Teams::Glad
    @scores = Hash(Teams, Int32).new
    @scores[Teams::Glad] = 0
    @scores[Teams::Mad] = 0
    @round_start_time = Time.utc

    @curr_glad_player = 0
    @curr_mad_player = -1
    @players_by_team = Hash(Teams, Array(Base_Player)).new
    players.each do |player|
      if !@players_by_team.has_key?(player.team)
        @players_by_team[player.team] = [] of Base_Player
      end
      @players_by_team[player.team] << player
    end
  end

  def draw_new_card
    time_since_round_start = (Time.utc - @round_start_time).to_i
    if time_since_round_start > @round_length
      return nil
    end

    curr_card_idx = Random.rand(@deck.size)
    curr_card = @deck[curr_card_idx]
    @deck.delete_at(curr_card_idx)
    @drawn_cards << curr_card

    if @curr_team == Teams::Glad
      @players_by_team[Teams::Glad][@curr_glad_player].send_message "#{curr_card[0]} #{curr_card[1]}"
    else
      @players_by_team[Teams::Mad][@curr_mad_player].send_message "#{curr_card[0]} #{curr_card[1]}"
    end

    return curr_card
  end

  def add_three
    update_score(3)
  end

  def add_one
    update_score(1)
  end

  def minus_one
    update_score(-1)
  end

  private def update_score(num)
    if @curr_team.is_a? Teams
      @scores[@curr_team] += num
    end
  end

  private def switch_team
    if @curr_team == Teams::Glad
      @curr_team = Teams::Mad
    else
      @curr_team = Teams::Glad
    end
  end

  def next_round
    switch_team
    @round_start_time = Time.utc
    
    if @curr_team == Teams::Glad
      @curr_glad_player = (@curr_glad_player + 1) % @players_by_team[Teams::Glad].size
    else
      @curr_mad_player = (@curr_mad_player + 1) % @players_by_team[Teams::Mad].size
    end
  end

  def drawn_cards
    @drawn_cards
  end

  def deck
    @deck
  end

  def curr_team
    @curr_team
  end

  def scores
    @scores
  end
end


class Base_Player
  def initialize(@name : String, @team : Teams)
    @last_message = ""
  end

  def send_message(msg : String)
    @last_message = msg
  end

  def team
    @team
  end

  def last_message
    @last_message
  end
end
