require 'faye'
Faye::WebSocket.load_adapter('thin')
bayeux = Faye::RackAdapter.new(
  :mount => '/faye',
  :timeout => 25,
  :engine  => {
  :host  => 'https://pacific-springs-41409.herokuapp.com',
  :port  => 3001
  })
run bayeux
