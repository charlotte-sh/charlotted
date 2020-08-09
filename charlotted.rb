require './requirements'

Thread.new { Server.new }
API.run! host: '0.0.0.0', port: 1913
