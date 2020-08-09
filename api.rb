class API < Sinatra::Base
  post '/session' do
    params = JSON(request.body.read)
    username = params['userdata']
    Session.where(username: username).destroy_all
    
    if params['type'] == 'session_register'
      session = Session.create(
        username: username,
        address: params['params']['ssh_cmd_fmt'] % params['params']['stoken']
      )
      json session: session.attributes
    end
  end
end
