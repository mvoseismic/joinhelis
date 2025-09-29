#!/usr/bin/env perl
#
# Creates multi-heli plot for today, run as a cronjob
#
# R.C.Stewart, 2025-09-29
#

use strict;
use warnings;

use DateTime;
use Getopt::Long;

my $noMagick = 1;
my $whichMagick = `which magick`;
if( length(  $whichMagick ) > 0  ){
    $noMagick = 0;
}

my @sta;
my $file_stub;
my $label_stub;

@sta = qw( MSS1_SHZ MBLG_HHZ ABD_HHZ );
$label_stub = '- - - - - - - - MSS1_SHZ - - - - - - - - - - - - - - - - - - - - MBLG_HHZ - - - - - - - - - - - - - - - - - - - - ABD_HHZ - - - - - - -';

# Edit here if you want to do set dates
 
my $today = DateTime->now;
my $start = DateTime->new(
    day   => $today->day,
    month => $today->month,
    year  => $today->year,
);

my $dir_heli = '/mnt/earthworm3/monitoring_data/helicorder_plots';
my $dir_heli_multi = '/mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots_multi';

my $fulldir_heli = join( '/', $dir_heli );

my $cmd = "magick convert -border 5 -bordercolor White +append";
if( $noMagick == 1 ) {
    $cmd =~ s/^magick //;
}

my $datestr = sprintf( '%4s%02s%02s', $start->year, $start->month, $start->day );

foreach my $sta (@sta) {

	opendir(DIR, $fulldir_heli) or die "$!";
	my @gfiles = grep{/^${sta}.*${datestr}00\.gif/} readdir(DIR);
	closedir(DIR);

	if( scalar @gfiles == 0 ) {
		$cmd = $cmd . " " . "blank.gif";
	} elsif( scalar @gfiles == 1 ) {
		foreach my $gfile (@gfiles) {
			$cmd = $cmd . " " . join( '/', $fulldir_heli, $gfile );
    	}
	} else {
	}
}


$cmd = $cmd . " -tile 3x1 -geometry +5+5 temp.gif";
system( $cmd );

$cmd = "magick convert -border 5 -bordercolor White temp.gif -background White -font Open-Sans -pointsize 54 label:'" . substr( $datestr, 0,4) . "-" . substr( $datestr,4,2) . "-" . substr($datestr,6,2) . " (gains not identical)" . "' +swap -append " .  "temp2.gif";
if( $noMagick == 1 ) {
    $cmd =~ s/^magick //;
}
system( $cmd );
$cmd = "magick convert -border 5 -bordercolor White temp2.gif -background White -font Open-Sans -pointsize 54 label:'" . $label_stub . "' -append " .  "helix.png";
if( $noMagick == 1 ) {
    $cmd =~ s/^magick //;
}
system( $cmd );

system( 'rm temp*.gif' );

my $file_here = "helix.png";
my $file_there = join( '/', $dir_heli_multi, $file_here );
$cmd = join( ' ', 'mv', $file_here, $file_there );
system( $cmd );




sub check_exists_command {
    my $check = `sh -c 'command -v $_[0]'`;
    return $check;
}
