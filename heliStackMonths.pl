#!/usr/bin/env perl
# 
# heliStackMonths.pl
#
# Join helicorders for all stations, for a month at a time
# 
# R.C.Stewart, 2023-07-20
#
use strict;
use warnings;
use DateTime;

my $start = DateTime->new(
    day   => 1,
    month => 1,
    year  => 2024
);
my $stop = DateTime->new(
    day   => 1,
    month => 3,
    year  => 2024
);


while ( $start <= $stop ) {
    print $start->ymd(''), "\n";
    my $end = $start->clone();
    $end->add( months => 1 );
    $end->subtract( days => 1 );
    my $cmd = join( ' ', './heliStack.pl', $start->ymd(''), $end->ymd('') );
    system( $cmd );
    $cmd = 'rm heliStack.M*.png';
    system( $cmd );
    $start->add( months => 1 );
}
