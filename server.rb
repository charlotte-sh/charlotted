class Server
  PORT = 1654
  WORKSPACE = 'Charlotte'

  def initialize
    @server = TCPServer.open(PORT)
    @clients = {}
    run
  end

  def send_packet(connection, channel, **data)
    connection.puts Packet.new(channel, **data)
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
    packet = Packet.parse(connection.gets.chomp)
    username = packet.data.dig(:username)
    @clients[connection] = username

    send_packet connection, :handshake,
      workspace: WORKSPACE,
      account: username,
      machines: @clients.values

    puts "#{@clients[connection]} connected"
  end

  def on_message(connection)
    packet = Packet.parse(connection.gets.chomp)

    case packet.channel
    when 'chat'
      message = packet.data.dig(:message)
      unless message.empty?
        @clients.each do |client, username|
          send_packet client, :chat,
            username: @clients[connection],
            message: message
        end

        puts "#{@clients[connection]} sent a message"
      end
    when 'machines'
      send_packet connection, :machines,
        machines: @clients.values
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
