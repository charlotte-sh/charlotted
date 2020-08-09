class Message
  attr_reader :connection
  attr_reader :channel
  attr_reader :data

  def initialize(connection, packet)
    @connection = connection
    @packet = packet
    @channel = packet.channel
    @data = packet.data
  end

  def respond(**data)
    response_packet = Packet.new(:response, **data)
    response_packet.id = @packet.id
    @connection.send :send_packet, response_packet
  end
end
