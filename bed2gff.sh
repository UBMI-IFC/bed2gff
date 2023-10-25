#!/usr/bin/bash

# SIMPLY BED TO GFF CONVERTER
#
# Carlos Peralta 
# Instituto de Fisiologia Celular, UNAM
# GPL3
#
# Takes a Bed and convert it as a GFF asumes that its a BED file of a single type of features
# by default the TYPE (GFF column 3) is set to "peak" the ATTRIBUTES column (GFF 9) is -
# is populated with a unique consecutive attribute named "Peak" and a "bedID" that takes the - 
# of the name column of the BED file (if exist). Only the first 6 columns of the BED file are
# considered, any extra information will be lost on this conversion tool. 
#
# A minimum of 3 columns are required on the input file. 
#
# Columns 4-6 of the BED file are optional but if you need info for the 5-6 columns all the 
# previous columns must be present. 

# Stdout colors 
error=`tput setaf 1`
info=`tput setaf 2`
warn=`tput setaf 3`
colorbg=`tput setab 1`
reset=`tput sgr0`
noinfo=false
typeg="peak"
featureg="peak"
mode=0

while getopts i:xt:f:h flag
do
    case $flag in
	i) inputfile=$OPTARG;;
	x) noinfo=true;;
	t) typeg=$OPTARG;;
	f) featureg=$OPTARG;;
	h) echo
	   echo "${warn}BED to GFF Converter: ${reset}"
     echo ""
     echo "Basic usage:"
	   echo "${info}bed2gff.sh -i[[input bed file]] > [[output GFF]]${reset}"
     echo ""
     echo "Additional options"
	   echo "${info}-x ---- Ignore 4th trough 6th BED file columns${reset}"
     echo "${info}-t ---- Type column information (default: peak)${reset}"
     echo "${info}-f ---- Feature column information (default: peak)${reset}"
	   echo "${info}-h ---- Show this message${reset}"
	   echo
	   exit;;
  *) echo "${error}Run bed2gtf.sh -h for help" 
     exit;;
    esac
done

# Check that input file is provided
if [ -z $inputfile ];
  then
    echo "${error}ERROR: This script requires an input file" 
    echo ""
    echo "    ${info}bed2gff -i [[input bed file]] > [[output GFF]]" 
    echo ''
    echo "${error}Run bed2gtf.sh -h for help" 
    exit
elif [ -f $inputfile ]; 
  then
    >&2 echo "${info}File exist"
    cat $inputfile | sed -e 's/\t/%/g' > bed.b2g
    colcount=$(head -1 bed.b2g | tr -cd "%" | wc -c) 
    if [ $colcount -lt 2 ]; then
      >&2 echo "${error}Error: $(($colcount+1)) columns detected; 3 is the minimum required"
      rm bed.b2g
      exit
    elif [[ $noinfo == true ]]; then
      >&2 echo "${error}$(($colcount+1)) columns detected: But -x argument was passed, only first 3 columns will be used"
      mode=3
    elif [ $colcount -gt 5 ]; then
      >&2 echo "${warn}$(($colcount+1)) columns detected: only the first 6 columns will be used" 
      mode=6
    else
      >&2 echo "${info}$(($colcount+1)) columns detected"
      mode=$(($colcount+1)) 
    fi
else
    echo "${error}ERROR: Input file does not exist, check spelling/path" 
    echo ""
    echo "${error}Run bed2gtf.sh -h for help" 
    exit
fi

#Functions to execute according to mode

coreParsing(){ # all modes
  cut -d % -f 1 bed.b2g > seqid.b2g
  cut -d % -f 2 bed.b2g > start.b2g
  cut -d % -f 3 bed.b2g > end.b2g
  seq $(wc -l bed.b2g | cut -f 1 -d ' ') | sed -e 's/.*/bed2gff.sh/'  > source.b2g
  seq $(wc -l bed.b2g | cut -f 1 -d ' ') | sed -e 's/.*/\./'  > phase.b2g
  seq $(wc -l bed.b2g | cut -f 1 -d ' ') | sed -e "s/.*/$typeg/"  > type.b2g
  seq $(wc -l bed.b2g | cut -f 1 -d ' ') | sed -e "s/^/$featureg p-/" | sed -e 's/$/;/' > attributes.b2g
}

makeStrand(){ #mode 3,4,5
  seq $(wc -l bed.b2g | cut -f 1 -d ' ') | sed -e 's/.*/\./'  > strand.b2g
}

makeScore(){ #mode 3,4,5,6
  seq $(wc -l bed.b2g | cut -f 1 -d ' ') | sed -e 's/.*/\./'  > score.b2g
}

keepNames(){ # mode 4,5,6
  cut -d % -f 4 bed.b2g > bedNames.b2g
  mv attributes.b2g oldatt.b2g
  sed -ie 's/$/bedID /' oldatt.b2g 
  paste -d '' oldatt.b2g bedNames.b2g | sed -e 's/$/;/' > attributes.b2g
}

copyStrand(){ #mode 6
  cut -d % -f 6 bed.b2g > strand.b2g
}

copyScore(){ #mode 5,6
  cut -d % -f 5 bed.b2g > score.b2g
}
buildGFF(){
  paste seqid.b2g source.b2g type.b2g start.b2g end.b2g score.b2g strand.b2g phase.b2g attributes.b2g
  rm *.b2g*
  >&2 echo "${warn}Success!" 
}

# Mode dependent action triggering 
if [ $mode == 0 ]; then
  >&2 echo "${error} ERROR: Something went wrong, sorry"
  rm *.b2g*
  exit
elif [ $mode == 3 ]; then
  coreParsing
  makeScore
  makeStrand
  buildGFF
elif [ $mode == 4 ]; then
  coreParsing
  keepNames
  makeScore
  makeStrand
  buildGFF
elif [ $mode == 5 ]; then
  coreParsing
  keepNames
  copyScore
  makeStrand
  buildGFF
elif [ $mode == 6 ]; then
  coreParsing
  keepNames
  copyScore
  copyStrand
  buildGFF
fi

