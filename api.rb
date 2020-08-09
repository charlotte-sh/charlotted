class API < Sinatra::Base
  post '/session' do
    username = params['userdata']
    Session.where(username: username).destroy_all
    
    Session.create(
      username: username,
      address: params['params']['ssh_cmd_fmt'] & params['params']['stoken']
    ) if params['userdata'] == 'session_register'
  end
end
