package MojoX::Plugin::Log::GELF;
use Mojo::Base 'Mojolicious::Plugin', -signatures;
use Mojo::JSON qw(encode_json);
use MojoX::Log::GELF 0.0.3;
use Feature::Compat::Try;

use version; our $VERSION = version->declare('v0.0.2');

my $CONFIG_KEY = 'MojoX::Plugin::Log::GELF';

sub register ($self, $app, $plugin_args = {}) {
  my $config      = $app->config->{$CONFIG_KEY} ||= {};
  my $stash_key   = $config->{meta_stash_key}   ||= 'MPLG_META';
  my $helper_name = $config->{helper_name}      ||= 'log_more';

  my $logger = $app->log(MojoX::Log::GELF->new($config));

  # Installer helper method proxy for MojoX::Log::GELF->log()
  $app->helper(
    $helper_name => sub ($c, @args) {
      my %p = ref($args[0]) ? %{ $args[0] } : @args;

      # Merge additional_fields from stash and %p
      my $request_meta = $c->stash->{$stash_key};
      my $args_meta    = $p{additional_fields};
      $p{additional_fields} = {    #
        $request_meta ? %$request_meta : (),
        $args_meta    ? %$args_meta    : (),
      };

      return $c->log->log(%p);
    }
  );

  # At the beginning of every http request,
  # Scrape data about the request and cache it into stash.
  # This metadata will be attached to every gelf message generated
  # with the log_more helper
  $app->hook(
    before_dispatch => sub ($c) {
      my $req           = $c->req;
      my $hidden_params = $c->config->{$CONFIG_KEY}->{hidden_params} || [qw/password/];
      my $meta          = $c->stash($stash_key);

      unless ($meta) {
        $meta = {};
        $c->stash($stash_key, $meta);
      }

      # Create a json string from params, excluding hidden params
      my %params = %{ $req->params->to_hash };
      delete $params{$_} for @$hidden_params;
      my $params_json = %params ? encode_json(\%params) : undef;

      # Stash deatils read from current request
      $meta->{request_id}      = $req->request_id;
      $meta->{request_address} = $c->tx->remote_address;
      $meta->{request_method}  = $req->method;
      $meta->{request_url}     = $req->url->to_abs->to_string;
      $meta->{request_path}    = $req->url->path->to_string;
      $meta->{response_code}   = $c->res->code;
      $meta->{request_params}  = $params_json;

      return 1;
    }
  );
}

=head1 NAME

MojoX::Plugin::Log::GELF - Replace Mojo::Log with MojoX::Log::GELF

=head1 SYNOPSIS

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

=head1 DESCRIPTION

This plugin replaces the default L<Mojo::Log> application log oject with
L<MojoX::Log::GELF>.

A helper method, B<log_more>, is provided to automatically attach
per-request metadata to a GELF log message. This helper method functions
identically to B<MojoX::Log::GELF/log>.

=head1 CONFIGURATION

This plugin looks for it's configuration within the Mojo configuration object
with the key B<MojoX::Plugin::Log::GELF>.

Available configuration options:

=over 4

=item B<host> I<optional>

Name of the host generating the log message. Will appear in the B<source>
attribute within graylog for all messages.

Defaults to value of hostname()

=item B<gelf_address> I<optional>

Hostname or ip address of GELF server.

Defaults to 127.0.0.1.

=item B<gelf_port> I<optional>

Port to connect to the GELF server

Defaults to 12201

=item B<gelf_protocol> I<optional>

Accepts string values B<tcp> or B<udp>.

Defaults to udp.

=item B<gelf_chunk_size> I<optional>

Defaults to 'wan'

=item B<additional_fields> I<optional>

Accepts a href of keys and values to be attached as metadata to log messgaes

=item B<meta_stash_key> I<optional>

Override the stash key used to store per-request data for B<log_more> helper

Default value MPLG_META

=back 4

=head1 COPYRIGHT and LICENSE

Copyright (C) mitch@mjac.dev

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

mjac mitch@mjac.dev

=head1 SEE ALSO

See also L<MojoX::Log::GELF>, L<Log::GELF::Util>, L<Mojolicious>, L<Mojo::Log>

=cut

1;
