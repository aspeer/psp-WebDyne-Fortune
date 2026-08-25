use strict;
use warnings;

use File::Spec;
use WebDyne::PSGI;

my $root = $ENV{'LAMBDA_TASK_ROOT'} || File::Spec->rel2abs('.');

WebDyne::PSGI->new(
    root   => $root,
    index  => 'app.psp',
    static => 1,
    conf   => 1,
)->to_app;
