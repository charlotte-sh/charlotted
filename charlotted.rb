require 'socket'

class Server
  PORT = 1654

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
    puts "#{@clients[connection]} connected"
  end

	def on_message(connection)
    message = connection.gets.chomp
		@clients.each { |connection, user_id| connection.puts "#{user_id}: #{message}" }
    puts "#{@clients[connection]} sent a message"
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
