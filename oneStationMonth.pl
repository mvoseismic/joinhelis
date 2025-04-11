#!/usr/bin/env perl
# 
# oneStationMonth.pl
#
# Join helicorders for one station, for one month
# 
# R.C.Stewart, 2023-07-06
#
use strict;
use warnings;
use DateTime;

my $dirHeli = '/mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots';
my $dirHeliMonth = '/mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots_station_month';
my $now = DateTime->today();

my ($sta, $month, $year) = @ARGV;

if (not defined $sta) {
    $sta = 'MBLY';
}
if (not defined $month) {
    $month = $now->month;
}
if (not defined $year) {
    $year= $now->year;
}

printf "%4s %02d %04d\n", $sta, $month, $year;

my $start = DateTime->new(
    day   => 1,
    month => $month,
    year  => $year,
);
$start->subtract( days => 1 );
my $stop;
if( $month == 12 ){
    $stop = DateTime->new(
        day   => 1,
        month => 1,
        year  => $year+1,
    );
} else {
    $stop = DateTime->new(
        day   => 1,
        month => $month+1,
        year  => $year,
    );
}

my $cmd;
$cmd = 'rm *.gif~*';
system( $cmd );

# Seismic
my $scnl = join( '_', $sta, 'HHZ_MV_00' );

while ( $start->add(days => 1) < $stop ) {
    my $fileHeli = '';
    my $fileHeli1 = sprintf "%s\.%s00\.gif", $scnl, $start->ymd('');
    $fileHeli1 = join( '/', $dirHeli, $start->year, $fileHeli1 );
    my $fileHeli2 = $fileHeli1;
    $fileHeli2 =~ s/HHZ_MV_00/BHZ_MV_00/;
    my $fileHeli3 = $fileHeli1;
    $fileHeli3 =~ s/HHZ_MV_00/BHZ_MV_--/;
    my $fileHeli4 = $fileHeli1;
    $fileHeli4 =~ s/HHZ_MV_00/BHZ_MV/;
    my $fileHeli5 = $fileHeli1;
    $fileHeli5 =~ s/HHZ_MV_00/SHZ_MV_00/;
    my $fileHeli6 = $fileHeli1;
    $fileHeli6 =~ s/HHZ_MV_00/SHZ_MV_--/;
    my $fileHeli7 = $fileHeli1;
    $fileHeli7 =~ s/HHZ_MV_00/SHZ_MV/;
    if( -e $fileHeli1 ) {
        $fileHeli = $fileHeli1;
    } elsif( -e $fileHeli2 ) {
        $fileHeli = $fileHeli2;
    } elsif( -e $fileHeli3 ) {
        $fileHeli = $fileHeli3;
    } elsif( -e $fileHeli4 ) {
        $fileHeli = $fileHeli4;
    } elsif( -e $fileHeli5 ) {
        $fileHeli = $fileHeli5;
    } elsif( -e $fileHeli6 ) {
        $fileHeli = $fileHeli6;
    } elsif( -e $fileHeli7 ) {
        $fileHeli = $fileHeli7;
    } else {
    }
    if( $fileHeli ne '' ){
        #        print $fileHeli, "\n";
        $cmd = join( ' ', 'cp', $fileHeli,
            sprintf "%s\.gif", $start->ymd('') );
    } else {
        #print "No file found\n";
        $cmd = join( ' ', 'cp', '/home/seisan/src/joinhelis/blankHeli.gif.0',
            sprintf "\.\/%s\.gif", $start->ymd('') );
    }
    system( $cmd );
}

$cmd = 'magick mogrify -resize 33% *.gif';
system( $cmd );

$start->subtract( days => 1 );
my $fileOut = sprintf '%4s-seismic--%04d-%02d--%s_%04d.png', $sta, $year, $month, $start->month_name, $year;
$cmd = sprintf 'montage *.gif -tile 7x5 -geometry +5+5 %s', $fileOut;
#print $cmd, "\n";
system( $cmd );

my $size = -s $fileOut;
#print $size, "\n";

if( $size > 50000 ){ 
    $cmd = join( ' ', 'cp', $fileOut, sprintf( '%s/%4d/', $dirHeliMonth, $year ) );
    system( $cmd );
    $cmd = join( ' ', 'mogrify -resize 100x', $fileOut );
    system( $cmd );
    $cmd = join( ' ', 'mv', $fileOut, sprintf( '%s/0-thumbnails/', $dirHeliMonth ) );
    system( $cmd );
} else {
    unlink($fileOut)                 or die "Can't delete $fileOut$!\n";
}

$cmd = 'rm *.gif';
system( $cmd );


# Infrasound
$start = DateTime->new(
    day   => 1,
    month => $month,
    year  => $year,
);
$start->subtract( days => 1 );

$scnl = join( '_', $sta, 'HDF_MV_00' );

while ( $start->add(days => 1) < $stop ) {
    my $fileHeli = '';
    my $fileHeli1 = sprintf "%s\.%s00\.gif", $scnl, $start->ymd('');
    $fileHeli1 = join( '/', $dirHeli, $start->year, $fileHeli1 );
    my $fileHeli2 = $fileHeli1;
    $fileHeli2 =~ s/HDF_MV_00/HDF_MV/;
    if( -e $fileHeli1 ) {
        $fileHeli = $fileHeli1;
    } elsif( -e $fileHeli2 ) {
        $fileHeli = $fileHeli2;
    }
    if( $fileHeli ne '' ){
        #        print $fileHeli, "\n";
        $cmd = join( ' ', 'cp', $fileHeli,
            sprintf "%s\.gif", $start->ymd('') );
    } else {
        #print "No file found\n";
        $cmd = join( ' ', 'cp', '/home/seisan/src/joinhelis/blankHeli.gif.0',
            sprintf "\.\/%s\.gif", $start->ymd('') );
    }
    system( $cmd );
}

$cmd = 'magick mogrify -resize 33% *.gif';
system( $cmd );

$start->subtract( days => 1 );
$fileOut = sprintf '%4s-infrasound--%04d-%02d--%s_%04d.png', $sta, $year, $month, $start->month_name, $year;
$cmd = sprintf 'magick montage *.gif -tile 7x5 -geometry +5+5 %s', $fileOut;
#print $cmd, "\n";
system( $cmd );

$size = -s $fileOut;
#print $size, "\n";

if( $size > 50000 ){ 
    $cmd = join( ' ', 'cp', $fileOut, sprintf( '%s/%4d/', $dirHeliMonth, $year ) );
    system( $cmd );
    $cmd = join( ' ', 'magick mogrify -resize 100x', $fileOut );
    system( $cmd );
    $cmd = join( ' ', 'mv', $fileOut, sprintf( '%s/0-thumbnails/', $dirHeliMonth ) );
    system( $cmd );
} else {
    unlink($fileOut)                 or die "Can't delete $fileOut$!\n";
}

$cmd = 'rm *.gif';
system( $cmd );
