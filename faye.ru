require 'faye'
Faye::WebSocket.load_adapter('thin')
bayeux = Faye::RackAdapter.new(
  :mount => '/faye',
  :timeout => 25,
  :engine  => {
  :host  => 'https://intense-meadow-95262.herokuapp.com/',
  :port  => 3001
  })
run bayeux
