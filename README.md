# Membrane Multimedia Framework: DTLS Plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_dtls_plugin.svg)](https://hex.pm/packages/membrane_dtls_plugin)
[![CircleCI](https://circleci.com/gh/membraneframework/membrane_dtls_plugin.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_dtls_plugin)

This plugin provides DTLS (including DTLS-SRTP one) implementation of Handshake behaviour for [Membrane ICE Plugin].

## Installation

The package can be installed by adding `membrane_dtls_plugin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_dtls_plugin, "~> 0.1.0"}
  ]
end
```

## Usage
Use this plugin as `handshake module` in [Membrane ICE Plugin].

```elixir
source: %Membrane.ICE.Source{
  stun_servers: ["ip:port"],
  controlling_mode: false,
  handshake_module: Membrane.ICE.Handshake.DTLS,
  handshake_opts: [client_mode: true, dtls_srtp: true]
}
```

## Copyright and License

Copyright 2020, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_dtls_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_dtls_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)

[Membrane ICE Plugin](https://github.com/membraneframework/membrane_ice_plugin.git)
