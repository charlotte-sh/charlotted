requirements = %w(
  socket
  securerandom
  json
  sinatra/base
  active_record
  ./database
  ./server
  ./api
)

requirements += Dir['./communication/*']
requirements += Dir['./models/*']

requirements.each { |requirement| require requirement }
