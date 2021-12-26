# NAME

MojoX::Plugin::Log::GELF - Replace Mojo::Log with MojoX::Log::GELF

# SYNOPSIS

    # Configure and load the plugin
    $app->config->{'MojoX::Plugin::Log::GELF'} = {
      min_level     => 'debug',
      gelf_address  => 'graylog.example.com',
      gelf_port     => 12201,
      gelf_protocol => 'udp',
      additional_fields => {
        facility => 'my_app.pl',
      },
    };
    push @{ $app->plugins->namespaces }, 'Fwa::Mojo::Plugin', 'MojoX::Plugin';
    $app->plugin('Log::GELF');

    # Log messages are transmitted to GELF
    $app->log->info('Hello planet');

    # Helper log_more attaches per-request metadata to GELF messages
    $app->log_more(
      level => 'info',
      message => 'You must be thinking of some other band',
      additional_fields => {
        dont_lets_start => 'this is the worst part',
      },
    );

# DESCRIPTION

This plugin replaces the default [Mojo::Log](https://metacpan.org/pod/Mojo%3A%3ALog) application log oject with
[MojoX::Log::GELF](https://metacpan.org/pod/MojoX%3A%3ALog%3A%3AGELF).

A helper method, **log\_more**, is provided to automatically attach
per-request metadata to a GELF log message. This helper method functions
identically to **MojoX::Log::GELF/log**.

# CONFIGURATION

This plugin looks for it's configuration within the Mojo configuration object
with the key **MojoX::Plugin::Log::GELF**.

Available configuration options:

- **host** _optional_

    Name of the host generating the log message. Will appear in the **source**
    attribute within graylog for all messages.

    Defaults to value of hostname()

- **gelf\_address** _optional_

    Hostname or ip address of GELF server.

    Defaults to 127.0.0.1.

- **gelf\_port** _optional_

    Port to connect to the GELF server

    Defaults to 12201

- **gelf\_protocol** _optional_

    Accepts string values **tcp** or **udp**.

    Defaults to udp.

- **gelf\_chunk\_size** _optional_

    Defaults to 'wan'

- **additional\_fields** _optional_

    Accepts a href of keys and values to be attached as metadata to log messgaes

- **meta\_stash\_key** _optional_

    Override the stash key used to store per-request data for **log\_more** helper

    Default value MPLG\_META

# COPYRIGHT and LICENSE

Copyright (C) mitch@mjac.dev

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

mjac mitch@mjac.dev

# SEE ALSO

See also [MojoX::Log::GELF](https://metacpan.org/pod/MojoX%3A%3ALog%3A%3AGELF), [Log::GELF::Util](https://metacpan.org/pod/Log%3A%3AGELF%3A%3AUtil), [Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojo::Log](https://metacpan.org/pod/Mojo%3A%3ALog)

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 91:

    &#x3d;back doesn't take any parameters, but you said =back 4
