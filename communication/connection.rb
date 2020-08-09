class Connection
  def initialize(socket, on_request: nil, on_close: nil)
    @socket = socket
    @on_request = on_request
    @on_close = on_close
    @response_handlers = {}
    listen
  end

  def request(channel, **data)
    request_packet = Packet.new(channel, **data)
    @response_handlers[request_packet.id] = -> (message) { yield(message) } if block_given?
    send_packet request_packet
  end

  def listen
    Thread.new do
      loop do
        if @socket.eof?
          @socket.close
          @on_close&.call self
          Thread.stop
        else
          receive_packet
        end

        sleep 0.01
      end
    end
  end

  private

  def send_packet(packet)
    @socket.puts packet
    # puts "▶ #{packet}"
  end

  def receive_packet
    packet = Packet.parse(@socket.gets.chomp)
    message = Message.new(self, packet)
    # puts "◀ #{packet}"

    if packet.response?
      @response_handlers.dig(packet.id)&.call message
    else
      @on_request&.call message
    end
  end
end
