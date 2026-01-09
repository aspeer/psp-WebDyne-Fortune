use strict;
use vars qw($VERSION);
use Fortune;
use HTML::Entities;
use File::Basename qw(dirname);
use File::Spec;
$VERSION='1.050';
my $fn=File::Spec->rel2abs(File::Spec->catfile(dirname(__FILE__), 'perl'));
my $fortune_or=Fortune->new($fn);
$fortune_or->read_header();

sub fortune {
    return encode_entities($fortune_or->get_random_fortune());
}
