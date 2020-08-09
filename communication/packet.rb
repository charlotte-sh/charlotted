class Packet
  attr_accessor :id
  attr_accessor :channel
  attr_accessor :data

  def self.parse(json)
    hash = JSON(json, symbolize_names: true)
    packet = new hash.dig(:payload, :channel), **hash.dig(:payload, :data)
    packet.id = hash.dig(:id)
    packet
  end

  def initialize(channel, **data)
    @id = SecureRandom.uuid
    @channel = channel.to_sym
    @data = data
  end

  def response?
    @channel == :response
  end

  def to_s
    {
      id: @id,
      payload: {
        channel: @channel,
        data: @data
      }
    }.to_json
  end
end
