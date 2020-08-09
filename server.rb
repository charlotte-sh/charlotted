class Server
  PORT = 1654
  WORKSPACE = 'charlotte'

  def initialize
    @server = TCPServer.open(PORT)
    @connections = {}
    run
  end

  private

  def run
    Socket.accept_loop(@server) do |socket|
      connection = Connection.new socket,
        on_request: -> (message) { on_request(message) },
        on_close: -> (connection) { on_close(connection) }

      @connections[connection] = {}
      puts 'connected'
    end
  end

  def on_request(request)
    case request.channel
    when :authentication
      username = request.data.dig(:username)
      @connections[request.connection][:username] = username
      request.respond(
        username: username,
        workspace: WORKSPACE
      )

    when :machines
      machines = @connections.values.map { |x| x.dig(:username) }
      request.respond machines: machines

    when :shell
      username = request.data.dig(:username)
      session = Session.find_by(username: username)
      source_connection = request.connection
      target_connection = @connections.select { |k, v| v.dig(:username) == username }.first.first
      [source_connection, target_connection].each do |connection|
        connection.request :shell, address: session.address
      end

    when :chat
      message = request.data.dig(:message)

      unless message.empty?
        @connections.each do |connection, meta|
          next if connection == request.connection

          connection.request :chat,
            username: @connections[request.connection].dig(:username),
            message: message
        end
      end
    end
  end

  def on_close(connection)
    puts "disconnected"
    @connections.delete(connection)
  end
end
