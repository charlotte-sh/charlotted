require './requirements'

Thread.new { Server.new }
API.run! host: 'localhost', port: 1234
