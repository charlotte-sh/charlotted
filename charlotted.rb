require 'socket'

PORT = 1654

class Server
	def initialize(socket_port)
		@server = TCPServer.open(socket_port)
		@clients = {}
    run
  end

  private

  def run
    Socket.accept_loop(@server) do |connection|
			Thread.new do
        handshake(connection)
        handle_messages(connection)
			end
    end
	end

  def handshake(connection)
		user_id = connection.gets.chomp
		@clients[connection] = user_id
    puts "#{@clients[connection]} connected"
  end

  def handle_messages(connection)
  	loop do
      if connection.eof?
        on_disconnect(connection)
      else
  			on_message(connection)
      end
    end
  end

	def on_message(connection)
    message = connection.gets.chomp
		@clients.each { |connection, user_id| connection.puts "#{user_id}: #{message}" }
    puts "#{@clients[connection]} sent message"
	end

  def on_disconnect(connection)
    @clients.delete(connection)
    connection.close
    Thread.stop
    puts "#{@clients[connection]} disconnected"
  end
end

Server.new(PORT)
