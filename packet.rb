class Packet
  attr_accessor :channel
  attr_accessor :data

  def self.parse(json)
    hash = JSON(json, symbolize_names: true)
    new hash.dig(:payload, :channel), **hash.dig(:payload, :data)
  end

  def initialize(channel, **data)
    @channel = channel
    @data = data
  end

  def to_s
    {
      payload: {
        channel: @channel,
        data: @data
      }
    }.to_json
  end
end
