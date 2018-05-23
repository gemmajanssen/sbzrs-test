#!/bin/sh -x                                                                    

# GHJ 27-07-2016 based on MakeScrunchFiles 14-01-2010 
# to generate .Tp .Fp .FTp files for the whole band
# and .FTp for each band separately
# New: split off 8 overlap channels in the band as they are in there twice
# Re-add the frequencies, and the bands. New total BW is 70MHz.
# The redo the normal scrunching in time and frequency and both. Add one without polarisation.
# Test version to be run in pulsar-freq directory
# e.g. in J2317+1439-385/                                                       
# ./SingleProfiles.sh 2317+1439-385                                             
# the files will be generated in their date directories                         
# This does not affect the already existing PulsarFreq.Date.FTp, Fp, Tp files
# Janneke uses -o instead of -f for filename output
# Zapping on the combined file to have better coverage on band edges
# Make ToAs from the semi-scrunched files

    PulsarDir=$1
    Dates=`ls -d *20* `
#    Dates=`ls -d * | grep 20 | grep -v 2007 | grep -v 2008 | grep -v 2009 | grep -v 2010 | grep -v 2011`
#    Dates=01Apr2015
    NewDM="20.733"

    for	date in	$Dates
    do	
     cd	$date
     Nbands=`ls add-?.ITd | wc -l`
     echo "Nbands is $Nbands"

     psrsplit -n 1 -c 8 add-?.ITd
     for band in 0 1 2 3 4 5 6 7
#     for band in 0 
     do 
	 psradd -o add-$band.ITds -R add-$band.000[0-6]*.ITd
	 if [ -s add-$band.ITds ]; then
	     echo "it exists"
	     rm add-$band.00*.ITd
	 else
	     echo "no med files"
	 fi
     done
     psradd -o $PulsarDir.$date.ITds -R add-?.ITds
     psrsh ~/code/median_zap.psh -e med $PulsarDir.$date.ITds
     pam -e Tpds -Tp -d $NewDM $PulsarDir.$date.med
     pam -e fTpds --setnchn $Nbands -d $NewDM $PulsarDir.$date.Tpds
     pam -e Fpds -Fp -d $NewDM $PulsarDir.$date.med
     pam -e FTpds -FTp -d $NewDM $PulsarDir.$date.med
     pam -e FTds -FT -d $NewDM $PulsarDir.$date.med
     cd ..
    done
