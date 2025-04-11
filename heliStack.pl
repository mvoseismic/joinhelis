#!/usr/bin/env perl
# 
# heliStack.pl
#
# Join helicorders for all stations, for a given period
# 
# R.C.Stewart, 2023-07-19
#
use strict;
use warnings;
use DateTime;
use Image::Size;

my $dirHeli = '/mnt/mvofls2/Seismic_Data/monitoring_data/helicorder_plots';
my $dirHeliOut = '.';
my $now = DateTime->today();

my ($dateBeg, $dateEnd) = @ARGV;

if (not defined $dateEnd) {
    $dateEnd = $now->ymd('');
}
if (not defined $dateBeg) {
    $dateBeg = $now->ymd('');
}

printf "%8s %8s\n", $dateBeg, $dateEnd;

my $start = DateTime->new(
    day   => int(substr( $dateBeg,6,2)),
    month => int(substr( $dateBeg,4,2)),
    year  => int(substr( $dateBeg,0,4))
);
$start->subtract( days => 1 );
my $stop = DateTime->new(
    day   => int(substr( $dateEnd,6,2)),
    month => int(substr( $dateEnd,4,2)),
    year  => int(substr( $dateEnd,0,4))
);


my $cmd;
#$cmd = 'rm *.gif';
#system( $cmd );

my @stations = qw( MSS1 MBFR MBLG MBLY MBRY MBBY MBHA MBGH MBWH MBFL MBGB MBRV );
#my @stations = qw( MBLY MBBY MBGH MBWH );
#my @stations = qw( MBFR MBLG MBLY MBRY );


while ( $start->add(days => 1) <= $stop ) {
    print $start->ymd(''), "\n";
    for my $sta (@stations){
        #print $sta, "\n";
        my $scnl = join( '_', $sta, 'HHZ_MV_00' );

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
        my $fileHere = sprintf "%s\.%s\.gif", $sta, $start->ymd('') ;
        if( $fileHeli ne '' ){
            #print $fileHeli, "\n";
            $cmd = join( ' ', 'cp', $fileHeli, $fileHere );
        } else {
            #print "No file found\n";
            $cmd = join( ' ', 'cp', '/home/seisan/src/joinhelis/blankHeli.gif.0',
                $fileHere );
        }   
        system( $cmd );
        my ($img_x, $img_y) = imgsize($fileHere);
        if( $img_x == 852 ){
            $cmd = join( ' ', 'convert', $fileHere, '-crop 810x1429+4+26 +repage -resize 500x500! tmp.gif' );
        } else {
            $cmd = join( ' ', 'convert', $fileHere, '-crop 867x1405+0+51 +repage -resize 500x500! tmp.gif' );
        }
        system( $cmd );
        $cmd = join( ' ', 'mv tmp.gif', $fileHere );
        system( $cmd );

    }
}

$cmd = 'magick convert -background white -fill black -gravity Center -pointsize 72 -size 500x200 label:Date date00000000.gif';
system( $cmd );
$start = DateTime->new(
    day   => int(substr( $dateBeg,6,2)),
    month => int(substr( $dateBeg,4,2)),
    year  => int(substr( $dateBeg,0,4))
);
$start->subtract( days => 1 );
while ( $start->add(days => 1) <= $stop ) {
    $cmd = join( '', 'magick convert -background white -fill black -gravity Center -pointsize 72 -size 500x500 label:', $start->dmy('/'), ' ', 'date', $start->ymd(''), '.gif' );
    #print $cmd, "\n";
    system( $cmd );
}
$cmd = 'magick montage date*.gif -tile 1x -geometry +1+1 dateAll.gif';
system( $cmd );

open( FH, ">list.txt" );
print FH "dateAll.gif\n";

for my $sta (@stations){
    my @stafiles = glob( "$sta*.gif" );

    $cmd = join( ' ', 'magick convert -background white -fill black -gravity Center -pointsize 72 -size 500x200', 
        sprintf( 'label:%s', $sta ), 
        sprintf( '%s.00000000.gif',  $sta ), );
    system( $cmd );
    my $fileMont = sprintf( 'heliStack.%s.%8s-%8s.png', $sta, , $dateBeg, $dateEnd );
    print FH $fileMont, "\n";
    $cmd = join( '', 'magick montage ', $sta, '*.gif -tile 1x', scalar(@stafiles)+1, ' -geometry +1+1 ', $fileMont );
    system( $cmd );

}
close( FH );

my $nsta = scalar( @stations );
my $fileAll = sprintf( 'heliStack.all.%8s-%8s.png', , $dateBeg, $dateEnd );
$cmd = join( '', 'montage @list.txt -tile ', 
	sprintf( '%d', $nsta+1 ), 
	'x1 -geometry +20+1 ', $fileAll );
system( $cmd );

$cmd = "magick convert $fileAll -bordercolor White -border 20 temp.png";
system( $cmd );
$cmd = "mv temp.png $fileAll";
system( $cmd );

$cmd = 'rm *.gif';
system( $cmd );

unlink 'list.txt';
