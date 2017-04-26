#!/bin/bash

# and DaViT env variables
source /davit/env/env_davit

# we loop backwards, so startdate > enddate
# format is yyyy-mm-dd
start_date=2017-04-04
end_date=2017-04-04

# set the time step of the files in minutes
# So far the options here are 1(no temporal averaging), 2, 5, and 10 minutes -KTS 20140514
# The default is 2.
timestep=2

# set input to -1 for fit input
# set input to +1 for fitex input
# set input to +2 for fitacf input, here fitacf input is prefered as fitex
# does not work on all rawacf files. -KTS, 5/1/2012
input=2
#input=-1

# set this to 11 to remove existing
# grid files and redo them
force=11

# set this to 11 to use AJ's fitexfilter
# and then not use temporal averaging in the
# make_grid command
filter=0

root_dir="/sd-data/"
if [ ${input} -eq -1 ]
then
	echo "fit format input"
	istring="fit"
	ostring="vtgrd"
	switch=""
elif [ ${input} -eq 1 ]
then
	echo "fitex format input"
	istring="fitex"
	ostring="grdex"
	switch="-new"
elif [ ${input} -eq 2 ]
then
	echo "fitacf format input"
	istring="fitacf"
	ostring="grdex"
	switch="-new"
else
	echo "INVALID INPUT FLAG"
	echo "Please edit script to use valid input flag"
	exit
fi

if [ ${filter} -eq 11 ]
then
	fswitch="-nav"
else
	fswitch=""
fi

# convert dates to seconds since 1970-01-01 00:00:00.00
ssec=`date -d "${start_date}" +%s`
fsec=`date -d "${end_date}" +%s`

# all radars
north_radar=(     gbr sch kap sas pgr kod sto pyk han ksr     wal bks hok inv rkn svb fhw fhe cvw cve ade adw cly hkw lyr )
#north_radar=(     gbr kap sas pgr sto pyk han ksr inv rkn )
#north_radar=( gbr )
north_radar_old=(  g   s   k   t   b   a   w   e   f   c   z   i   i   i )
south_radar=(     fir hal mcm san sys sye tig unw ker zho dce sps bpk )
#south_radar=(     dce )
south_radar_old=(  q   h   i   d   j   n   r   u   p )

# do both hemispheres, first do northern hemisphere
for (( hemi=0; hemi<=1; hemi++ ))

# only do the northern hemisphere
#for (( hemi=0; hemi<=0; hemi++ ))

# only do southern hemisphere
#for (( hemi=1; hemi<=1; hemi++ ))
do
	if test $hemi -eq 1
	then
		radar=( ${south_radar[@]} )
		radar_old=( ${south_radar_old[@]} )
		str_hemi="south"
	else
		radar=( ${north_radar[@]} )
		radar_old=( ${north_radar_old[@]} )
		str_hemi="north"
	fi
	nradar=${#radar[@]}

	# loop through all years after change to rawacf format
	# lets rather work backwards in time
	asec=$ssec
	while [ $asec -ge $fsec ]
	do
		adate=`date -d "1970-01-01 ${asec} sec" +%Y%m%d`
		ayear=`date -d "1970-01-01 ${asec} sec" +%Y`

		# setting the output directory
		# and creating it if neccessary
		outdir="./"
		if [ ! -d ${outdir} ]
		then
			mkdir ${outdir}
		fi

		# setting the output directory
		# and creating it if neccessary
		outdir="${outdir}${str_hemi}/"
		if [ ! -d ${outdir} ]
		then
			mkdir ${outdir}
		fi

		#Changing the output filename based on different timestep.
		if [ ${timestep} -eq 2 ]
		then
#			outfile="${outdir}${adate}.2min.nav.${str_hemi}.${ostring}"
			outfile="${outdir}${adate}.${str_hemi}.${ostring}"
		else
			outfile="${outdir}${adate}.${timestep}min.${str_hemi}.${ostring}"
		fi
		# check if grdex file exists
		if [ -e ${outfile} ]
		then
			echo "${outfile} exists."
			if [ $force -eq 11 ]
			then
				rm ${outfile}
			else
				# step down one day
				asec=$(( $asec - 86400 ))
				continue
			fi
		fi
		if [ -e "${outfile}.bz2" ]
		then
			echo "${outfile}.bz2 exists."
			if [ $force -eq 11 ]
			then
				echo "Overwriting."
				rm ${outfile}.bz2
			else
				# step down one day
				asec=$(( $asec - 86400 ))
				continue
			fi
		fi

		grdfiles=""
		# find all fit/fitEX files for that day for all
		# radars
		# cp them into vtgrd/grdex dir and unzip 'em
		echo "Searching, copying and unzipping for ${adate} ${str_hemi}..."
		for (( rad = 0; rad < $nradar; rad++ ))
		do
			aradar=${radar[$rad]}
			arad_old=${radar_old[$rad]}
			indir="${root_dir}${ayear}/${istring}/${aradar}/"
			if [ ! -d ${indir} ]
			then
				continue
			fi
			if [ ${input} -eq -1 ]
			then
				files=( `find ${indir} -name "${adate}??${arad_old}.${istring}.bz2" | sort` )
			else
				# Here wildcard '*' is used after aradar to follow multi-channel naming convention from UAF.
				# -KTS 14Aug2012
				files=( `find ${indir} -name "${adate}.*.${aradar}*.${istring}.bz2" | sort` )
			fi
			#echo ${files[@]}
			#exit 1;
			nfiles=${#files[@]}
			allfiles=""
			filecount=0
			echo "  Copying ${aradar}."
			for (( i=0; i<$nfiles; i++ ))
			do
				afile=${files[${i}]}
				#echo "  Doing ${files[$i]}"
				# check whether file contains data
				# we take the easy route and just look at the file size
				fsize=`stat -c %s ${afile}`
				if [ $fsize -lt 100 ]
				then
					echo "  ${afile} does not contain data."
					continue
				fi
				if [ ${input} -eq -1 ]
				then
					# check for multiple files ending in a, b, c etc.
					tbase=`basename ${afile} ".${istring}.bz2"`
					mafiles=( `find ${indir} -name "${tbase}[a-z].${istring}.bz2" | sort` )
					if test ${#mafiles[@]} -gt 0
					then
						# copy zipped fit files to grd directory
						afile=( ${afile} ${mafiles[@]} )
						echo "    Multiple input files found, concatenating"
						for (( afi=0; afi<=${#mafiles[@]}; afi++ ))
						do
							echo "      Copying  ${afile[$afi]}"
							cp ${afile[$afi]} ${outdir}
							afile[$afi]=`basename ${afile[$afi]}`
							bzip2 -df ${outdir}${afile[$afi]}
							afile[$afi]=${outdir}`basename ${afile[$afi]} ".bz2"`
						done
						# concat fit files
						cat_fit ${afile[@]} ${afile[0]}".tmp"
						mv ${afile[0]}".tmp" ${afile[0]}
						afile=${afile[0]}
						for (( afi=1; afi<=${#mafiles[@]}; afi++ ))
						do
							rm ${outdir}`basename ${afile[$afi]}`
						done
					else
						# copy zipped dat file to rawacf directory
						cp ${afile} ${outdir}
						afile=`basename ${afile}`
						bzip2 -df ${outdir}${afile}
						afile=${outdir}`basename ${afile} ".bz2"`
					fi
				else
					#cp ${afile} ${outdir}
					#afile=`basename ${afile}`
					nafile=${outdir}`basename ${afile} ".bz2"`
					echo "bzip2 -dc ${afile} > ${nafile}"
					bzip2 -dc ${afile} > ${nafile}
					if [ ${filter} -eq 11 ]
					then
						echo "Filtering ${nafile} -> ${nafile}.filtered"
						fitexfilter ${nafile} > ${nafile}.filtered
						rm ${nafile}
						afile=${nafile}.filtered
					else
						afile=${nafile}
					fi
				fi
				allfiles=${allfiles}" "${afile}
				filecount=$(( filecount + 1))
			done
			if [ $filecount -gt 0 ]
			then
				echo "  Gridding ${aradar}."
				outgrdfile="${outdir}${adate}.${aradar}.${ostring}"
				# Here -tl controls the length data that data will be read in in seconds.  If -tl is zero, then the the scan flag will stop
				# the reading in of data.  Also, -i controls the time step of the gridded data.  For example, -tl 120 -i 300 will produce
				# data in 5 minute steps but use data for only 2 minutes from the start (I believe) of the 5 minute time step.
				# -KTS 20140225
				#
				if [ ${timestep} -eq 2 ]
				then
					# Integrate 2 minutes worth of data when doing a grid
					echo "make_grid ${switch} ${fswitch} -xtd -tl 120 -i 120 -sd ${adate} -st 00:00 -cn A -c > ${outgrdfile}"
					make_grid ${switch} ${fswitch} -xtd -tl 120 -i 120 -sd ${adate} -st 00:00 -cn A -c ${allfiles} > ${outgrdfile}
					# and without data before or after the 2 minute window -KTS 20170407
#					echo "make_grid ${switch} ${fswitch} -xtd -tl 120 -i 120 -sd ${adate} -st 00:00 -nav -cn A -c > ${outgrdfile}"
#					make_grid ${switch} ${fswitch} -xtd -tl 120 -i 120 -sd ${adate} -st 00:00 -nav -cn A -c ${allfiles} > ${outgrdfile}
				# Otherwise, it's something that's not our default, so lets
				# treat it a little differently.
				elif [ ${timestep} -eq 1 ]
				then
					# Integrate 1 minute worth of data, this should not be our standard data product -KTS 20140225
					echo "make_grid ${switch} ${fswitch} -xtd -tl 60 -i 60 -sd ${adate} -st 00:00 -cn A -c > ${outgrdfile}"
					make_grid ${switch} ${fswitch} -xtd -tl 60 -i 60 -sd ${adate} -st 00:00 -cn A -c ${allfiles} > ${outgrdfile}
					# and without data before or after the 1 minute window -KTS 20150127
#					echo "make_grid ${switch} ${fswitch} -xtd -tl 60 -i 60 -sd ${adate} -st 00:00 -nav -cn A -c > ${outgrdfile}"
#					make_grid ${switch} ${fswitch} -xtd -tl 60 -i 60 -sd ${adate} -st 00:00 -nav -cn A -c ${allfiles} > ${outgrdfile}
				elif [ ${timestep} -eq 5 ]
				then
					# Integrate 5 minutes worth of data, this should not be our standard data product -KTS 20140225
					echo "make_grid ${switch} ${fswitch} -xtd -tl 300 -i 300 -sd ${adate} -st 00:00 -cn A -c > ${outgrdfile}"
					make_grid ${switch} ${fswitch} -xtd -tl 300 -i 300 -sd ${adate} -st 00:00 -cn A -c ${allfiles} > ${outgrdfile}
					# and without data before or after the 5 minute window -KTS 20150127
#					echo "make_grid ${switch} ${fswitch} -xtd -tl 300 -i 300 -sd ${adate} -st 00:00 -nav -cn A -c > ${outgrdfile}"
#					make_grid ${switch} ${fswitch} -xtd -tl 300 -i 300 -sd ${adate} -st 00:00 -nav -cn A -c ${allfiles} > ${outgrdfile}
				elif [ ${timestep} -eq 10 ]
				then
#					echo "make_grid ${switch} ${fswitch} -xtd -tl 600 -i 600 -sd ${adate} -st 00:00 -cn A -c > ${outgrdfile}"
#					make_grid ${switch} ${fswitch} -xtd -tl 600 -i 600 -sd ${adate} -st 00:00 -cn A -c ${allfiles} > ${outgrdfile}
					# Integrate 10 minutes worth of data without any data before or after the 10 minute window
					echo "make_grid ${switch} ${fswitch} -xtd -tl 600 -i 600 -sd ${adate} -st 00:00 -nav -cn A -c > ${outgrdfile}"
					make_grid ${switch} ${fswitch} -xtd -tl 600 -i 600 -sd ${adate} -st 00:00 -nav -cn A -c ${allfiles} > ${outgrdfile}
				fi
				fsize=`stat -c %s ${outgrdfile}`
				if [ $fsize -gt 100 ]
				then
					grdfiles=${grdfiles}" "${outgrdfile}
				else
					rm ${outgrdfile}
				fi
	 			rm ${allfiles}
			fi
		done
#		exit 1;
		echo "  Combining grd files."
		combine_grid ${switch} ${grdfiles} > ${outfile}
		bzip2 -f ${outfile}
		# check of output file is larger than 20 bytes
		# if not, delete it
		fsize=`stat -c%s ${outfile}.bz2`
		if [ "${fsize}" -lt 20 ]
		then
			rm ${outfile}.bz2
		fi
	 	rm ${grdfiles}
		echo "Done. ${outfile}"
		# step down one day
		asec=$(( $asec - 86400 ))
		#exit 1;
	done
done

echo "Script finished at:"
echo `date`
echo

exit 1;

