#!/usr/bin/env perl
#
# Creates multi-heli plots for series of dates
# v2, with options
# v3, with different station options
#
#

use strict;
use warnings;
use DateTime;
use Getopt::Long;

my $staGrp = '5.1';
my $dateBeg = "yesterday";
my $dateEnd = "yesterday";

GetOptions ('stagrp=s' => \$staGrp, 'datebeg=s' => \$dateBeg, 'dateend=s' => \$dateEnd );

my @sta;
my $file_stub;
my $label_stub;

if( $staGrp eq '5.2' ) {
    @sta = qw( MSS1_SHZ MBFR_HHZ MBLG_HHZ MBLY_HHZ MBRY_BHZ );
    $file_stub = 'MSS1_MBFR_MBLG_MBLY_MBRY';
    $label_stub = '- - - - - - - - MSS1 - - - - - - - - - - - - - - - - MBFR - - - - - - - - - - - - - - - - MBLG - - - - - - - - - - - - - - - - MBLY - - - - - - - - - - - - - - - - MBRY - - - - - - -';
} elsif( $staGrp eq '12' ) {
    @sta = qw( MSS1_SHZ MBFR_HHZ MBLG_HHZ MBLY_HHZ MBRY_BHZ MBBY_HHZ MBHA_HHZ MBGH_HHZ MBWH_HHZ MBFL_HHZ MBGB_HHZ MBRV_BHZ);
    $file_stub = 'MSS1_MBFR_MBLG_MBLY_MBRY_MBBY_MBHA_MBGH_MBWH_MBFL_MBGB_MBRV';
    $label_stub = '- MSS1 - MBFR - MBLG - MBLY - MBRY - MBBY - MBHA - MBGH - MBWH - MBFL - MBGB - MBRV -';
} else {
    @sta = qw( MSS1_SHZ MBLY_HHZ MBBY_HHZ MBGH_HHZ MBFL_HHZ );
    $file_stub = 'MSS1_MBLY_MBBY_MBGH_MBFL';
    $label_stub = '- - - - - - - - MSS1 - - - - - - - - - - - - - - - - MBLY - - - - - - - - - - - - - - - - MBBY - - - - - - - - - - - - - - - - MBGH - - - - - - - - - - - - - - - - MBFL - - - - - - -';
}

# Edit here if you want to do set dates
 
my $start = DateTime->new(
    day   => 30,
    month => 10,
    year  => 2024,
);
my $stop = DateTime->new(
    day   => 31,
    month => 10,
    year  => 2024,
);

# Uncomment if you want to do yesterday only
#my $yesterday = DateTime->now->subtract( days => 1 );
#my $yyesterday = DateTime->now->subtract( days => 2 );
#my $start = DateTime->new(
#    day   => $yyesterday->day,
#    month => $yyesterday->month,
#    year  => $yyesterday->year,
#);
#my $stop = DateTime->new(
#    day   => $yesterday->day,
#    month => $yesterday->month,
#    year  => $yesterday->year,
#);

my $dir_heli = '/mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots';
#my $dir_heli_multi = '/mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots_multi';
my $dir_heli_multi = './helicorder_plots_multi';


while ( $start->add(days => 1) <= $stop ) {

    my $subdir_heli = sprintf( '%4s', $start->year );
    my $fulldir_heli = join( '/', $dir_heli, $subdir_heli );
    #printf "%s\n", $start->ymd;

    my $cmd;
    if( $staGrp eq '12' ) {
        $cmd = "montage";
    } else {
        #$cmd = "convert -border 20 -bordercolor White +append";
        $cmd = "magick convert -border 20 -bordercolor White +append";
    }

    my $datestr = sprintf( '%4s%02s%02s', $start->year, $start->month, $start->day );
    #printf "%s\n", $datestr;

	foreach my $sta (@sta) {

		opendir(DIR, $fulldir_heli) or die "$!";
		#my @gfiles = grep{/^${sta}.*${datestr}.*/} readdir(DIR);
		my @gfiles = grep{/^${sta}.*${datestr}00\.gif/} readdir(DIR);
		closedir(DIR);
		#print $sta . "  "  . scalar(@gfiles), "\n";

		if( scalar @gfiles == 0 ) {
			my $sta2 = $sta;
			$sta2 =~ s/HHZ/BHZ/;
			opendir(DIR, $fulldir_heli) or die "$!";
			#@gfiles = grep{/^${sta2}.*${datestr}.*/} readdir(DIR);
			@gfiles = grep{/^${sta2}.*${datestr}00\.gif/} readdir(DIR);
			closedir(DIR);
			#print $sta2 . "  "  . scalar(@gfiles), "\n";
		}

		if( scalar @gfiles == 0 ) {
			$cmd = $cmd . " " . "blank.gif";
		} elsif( scalar @gfiles == 1 ) {
			foreach my $gfile (@gfiles) {
				$cmd = $cmd . " " . join( '/', $fulldir_heli, $gfile );
			}
		} else {
		}
	}


    if( $staGrp eq '12' ) {
        $cmd = $cmd . " -tile 6x2 -geometry +50+50 temp.gif";
    } else {
	    $cmd = $cmd . " " . "temp.gif";
    }
        
    #print $cmd, "\n";
	system( $cmd );
    #$cmd = "convert -border 50 -bordercolor White temp.gif -background White -pointsize 72 label:'" . substr( $datestr, 0,4) . "-" . substr( $datestr,4,2) . "-" . substr($datestr,6,2) . " (gains not identical)" . "' +swap -append " .  "temp2.gif";
	$cmd = "magick convert -border 50 -bordercolor White temp.gif -background White -pointsize 72 label:'" . substr( $datestr, 0,4) . "-" . substr( $datestr,4,2) . "-" . substr($datestr,6,2) . " (gains not identical)" . "' +swap -append " .  "temp2.gif";
	#print $cmd, "\n";
	system( $cmd );
    #$cmd = "convert -border 50 -bordercolor White temp2.gif -background White -pointsize 72 label:'" . $label_stub . "' -append " .  $file_stub . "." . $datestr . ".gif";
	$cmd = "magick convert -border 50 -bordercolor White temp2.gif -background White -pointsize 72 label:'" . $label_stub . "' -append " .  $file_stub . "." . $datestr . ".gif";
	#print $cmd, "\n";
	system( $cmd );

  	my $fulldir_heli_multi = join( '/', $dir_heli_multi, $subdir_heli );
	my $file_here = join( '', $file_stub, '.', $datestr, '.gif' );
	my $file_there = join( '/', $fulldir_heli_multi, $file_here );
	$cmd = join( ' ', 'mv', $file_here, $file_there );
	#print $cmd, "\n";
    system( $cmd );


}
