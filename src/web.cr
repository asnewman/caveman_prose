require "json"
require "http/server"
require "./game.cr"

enum MessageTypes
  Message
  Draw
  Next_Round
  Start
end

def create_message(message_type : String, message_payload)
  return {"type" => message_type, "payload" => message_payload}.to_json
end

class Web_Player < Base_Player
  def initialize(@name : String, @team : Teams, @socket : HTTP::WebSocket)
    super(@name, @team)
  end

  def send_message(msg : String)
    super msg
    @socket.send(create_message(MessageTypes::Message.to_s, msg))
  end

  def socket
    @socket
  end
end

web_players = [] of Web_Player

game: Game | Nil = nil

ws_handler = HTTP::WebSocketHandler.new do |socket|
  puts "New player detected"
  if web_players.size % 2 == 0
    new_player = Web_Player.new("Player #{web_players.size}", Teams::Glad, socket)
  else
    new_player = Web_Player.new("Player #{web_players.size}", Teams::Mad, socket)
  end
  web_players << new_player

  web_players.each do |web_player|
    web_player.socket.send create_message(MessageTypes::Message.to_s, "#{new_player.name} has joined")
  end

  socket.on_close do
    web_players.delete(new_player)
  end

  socket.on_message do |message|
    puts "Received message: #{message}"

    if message == MessageTypes::Start.to_s && web_players.size >= 2
      puts "Message received to start game"
      game = Game.new([{"hand", "handcuff"}, {"dog", "dog walk"}], 60, web_players)
    end

    if game.nil?
      next
    end

    if message == MessageTypes::Draw.to_s
      game.not_nil!.draw_new_card
    elsif message == MessageTypes::Next_Round.to_s
      game.not_nil!.next_round
    end
  end
end

server = HTTP::Server.new([ws_handler])
address = server.bind_tcp "0.0.0.0", 3000
puts "Listening on ws://#{address}"
server.listen
