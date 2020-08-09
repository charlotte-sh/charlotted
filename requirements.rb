requirements = %w(
  socket
  securerandom
  json
  sinatra/base
  sinatra/json
  active_record
  ./database
  ./server
  ./api
)

requirements += Dir['./communication/*']
requirements += Dir['./models/*']

requirements.each { |requirement| require requirement }
