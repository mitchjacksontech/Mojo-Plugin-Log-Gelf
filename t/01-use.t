#!/usr/bin/local perl
use 5.006;
use strict;
use warnings;
use Test::More;

BEGIN {
  plan tests => 1;

  use_ok('MojoX::Plugin::Log::GELF');
}

done_testing();
