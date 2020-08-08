require 'socket'

class Server
  PORT = 1654
  WORKSPACE = 'Charlotte'

  def initialize
    @server = TCPServer.open(PORT)
    @clients = {}
    run
  end

  private

  def run
    Socket.accept_loop(@server) do |connection|
      Thread.new { handle(connection) }
    end
  end

  def handle(connection)
    loop do
      if connection.eof?
        on_disconnect(connection)
      elsif @clients[connection].nil?
        on_handshake(connection)
      else
        on_message(connection)
      end
    end
  end

  def on_handshake(connection)
    user_id = connection.gets.chomp
    @clients[connection] = user_id

    online_users = @clients.values - [user_id]
    connection.puts "Workspace: #{WORKSPACE}"
    connection.puts "Account:   #{user_id}"
    connection.puts "Online:    #{online_users.join(', ')}"
    connection.puts
    puts "#{@clients[connection]} connected"
  end

  def on_message(connection)
    message = connection.gets.chomp

    case message
    when /\/.*/
    when '/machines'
      connection.puts @clients.values.map { |x| x.dup.prepend '- ' }
      connection.puts
    else
      unless message.empty?
        @clients.each { |client, user_id| client.puts "#{@clients[connection]}: #{message}" }
        puts "#{@clients[connection]} sent a message"
      end
    end
  end

  def on_disconnect(connection)
    unless @clients[connection].nil?
      puts "#{@clients[connection]} disconnected"
      @clients.delete(connection)
    end

    connection.close
    Thread.stop
  end
end

Server.new
