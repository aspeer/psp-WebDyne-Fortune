use utf8;
use strict;
use warnings;

our $TASK_ROOT;
BEGIN {
    require Config;
    $TASK_ROOT = $ENV{'LAMBDA_TASK_ROOT'} || '.';
    unshift @INC,
        "$TASK_ROOT/local/lib/perl5/$Config::Config{'archname'}",
        "$TASK_ROOT/local/lib/perl5",
        $TASK_ROOT;
}

use AWS::Lambda::PSGI;

my $app  = require "$TASK_ROOT/app.psgi";
my $func = AWS::Lambda::PSGI->wrap($app);

sub handle {
    return $func->(@_);
}

1;
