require 'faye'
Faye::WebSocket.load_adapter('thin')
bayeux = Faye::RackAdapter.new(
  :mount => '/faye',
  :timeout => 25,
  :engine  => {
  :host  => '192.168.8.100',
  :port  => 3001
  })
run bayeux
