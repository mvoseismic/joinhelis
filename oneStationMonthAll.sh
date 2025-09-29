#!/usr/bin/bash

#for yr in {2008..2009}
for yr in {2025..2025}
do
    for mo in {1..7}
    do
        ./oneStationMonth.pl MBBY ${mo} ${yr}
        ./oneStationMonth.pl MBFL ${mo} ${yr}
        ./oneStationMonth.pl MBFR ${mo} ${yr}
        ./oneStationMonth.pl MBGB ${mo} ${yr}
        ./oneStationMonth.pl MBGH ${mo} ${yr}
        ./oneStationMonth.pl MBHA ${mo} ${yr}
        ./oneStationMonth.pl MBLG ${mo} ${yr}
        ./oneStationMonth.pl MBLY ${mo} ${yr}
        ./oneStationMonth.pl MBRV ${mo} ${yr}
        ./oneStationMonth.pl MBRY ${mo} ${yr}
        ./oneStationMonth.pl MSS1 ${mo} ${yr}
        ./oneStationMonth.pl MBWH ${mo} ${yr}
    done
done
