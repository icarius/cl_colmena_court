# Default setup
Tor.setup do
  config.count      =   10,   # Init count
  config.port       =   9000, # Listen port start with 9000
  config.dir        =   Pathname.new('/tmp/tor'),  # 
  config.ipApi      =   'http://ip.plusor.cn/', # get tor ip
  config.ipParser   =   -> (body) { body[/\d{,3}\.\d{,3}\.\d{,3}\.\d{,3}/] },   # get tor ip
  # Specify a node(country)   " --ExitNodes {AU} --StrictNodes 1 "
  # Specify multiple nodes(country)   " --ExitNodes {AU,US,....} --StrictNodes 1 "
  # Node codes: https://countrycode.org
  config.command    =   -> (port) { "tor --ExitNodes {CL,BR,US} --StrictNodes 1 --RunAsDaemon 1 --HashedControlPassword \"\"  --ControlPort auto --PidFile #{Tor.dir(port)}/tor.pid --SocksPort #{port} --DataDirectory #{Tor.dir(port)}  --CircuitBuildTimeout 5 --KeepalivePeriod 60 --NewCircuitPeriod 15 --NumEntryGuards 8 --quiet" }
end