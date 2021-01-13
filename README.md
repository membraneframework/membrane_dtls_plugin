# Membrane DTLS plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_dtls_plugin.svg)](https://hex.pm/packages/membrane_dtls_plugin)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/membrane_dtls_plugin/)
[![CircleCI](https://circleci.com/gh/membraneframework/membrane_dtls_plugin.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_dtls_plugin)

DTLS and DTLS-SRTP Handshake implementation for [Membrane ICE Plugin](https://github.com/membraneframework/membrane_ice_plugin).

## Installation

The package can be installed by adding `membrane_dtls_plugin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_dtls_plugin, "~> 0.2.0"}
  ]
end
```

## Usage
Use this plugin as `handshake_module` in [Membrane ICE Plugin](https://github.com/membraneframework/membrane_ice_plugin.git).

```elixir
source: %Membrane.ICE.Source{
  stun_servers: ["ip:port"],
  controlling_mode: false,
  handshake_module: Membrane.DTLS.Handshake,
  handshake_opts: [client_mode: true, dtls_srtp: true]
}
```

## Copyright and License

Copyright 2020, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_dtls_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_dtls_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)
