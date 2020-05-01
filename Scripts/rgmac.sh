#!/bin/bash
#
# For randomly generating MAC address
#
# Usage:  rgmac.sh [mode]
#    e.g. rgmac.sh                       -- Locally administered address (like MAC Randomization)
#    e.g. rgmac.sh -m 3C:E0:72           -- Make a Apple MAC (Fake MAC)
#    e.g. rgmac.sh -i console:Sony       -- Make a SonyPS MAC (Fake MAC) See Vendor/ directory
# 
# Mode:
#    -m <xx:xx:xx>                       -- Specify OUI manually
#    -i <VendorType:NameID>              -- Use IEEE public OUI
#    -u                                  -- Update locale OUI list"



# Init
OUIFILE=../Res/oui.txt
VENDORLIST=../Vendor/
OUIURL='https://code.wireshark.org/review/gitweb?p=wireshark.git;a=blob_plain;f=manuf'
pushd $VENDORLIST>/dev/null && VENDOR=`ls -1 *.txt` && popd>/dev/null

function version_message()
{
printf "rgmac.sh\n\
Src: https://github.com/muink/rgmac\n"
}

function usage_message() {
printf "\n\
For randomly generating MAC address\n\
\n\
Usage:  rgmac.sh [mode]\n\
   e.g. rgmac.sh                       -- Locally administered address (like MAC Randomization)\n\
   e.g. rgmac.sh -m 3C:E0:72           -- Make a Apple MAC (Fake MAC)\n\
   e.g. rgmac.sh -i console:Sony       -- Make a SonyPS MAC (Fake MAC) See Vendor/ directory\n\
\n\
Mode:\n\
   -m <xx:xx:xx>                       -- Specify OUI manually\n\
   -i <VendorType:NameID>              -- Use IEEE public OUI\n\
   -u                                  -- Update locale OUI list\n"
}

function update_oui() {
  curl -Lso "$OUIFILE" "$OUIURL"
}

function random_part() {
  echo $(echo `od -An -N2 -i /dev/random`|md5sum|cut -c 1-${1})
}

function randnum() {
    local min=$1
    local max=$(($2-$min+1))
    local num=$(cat /dev/urandom | head -n 10 | cksum | cut -f1 -d' ')
    echo $(($num%$max+$min))
}

function make_mac() {
  OUI=`echo "$1" | sed -n '/^[0-f][0-f]:[0-f][0-f]:[0-f][0-f]$/ p'`
  if [ "$OUI" == "" ] ; then printf "Invalid parameter: \"$1\"\n"; exit; fi
  NIC=`random_part 6`
  echo ${OUI}:${NIC:0:2}:${NIC:2:2}:${NIC:4:2} | tr 'a-z' 'A-Z'
}

function make_ven() {
  OUI=`pick_oui $1`
  if [ "$OUI" == "" ] ; then printf "Invalid parameter: \"$1\"\nAvailable vendor list can find in Vendor/ directory.\n"; exit; fi
  NIC=`random_part 6`
  echo ${OUI}:${NIC:0:2}:${NIC:2:2}:${NIC:4:2} | tr 'a-z' 'A-Z'
}

function pick_oui() {
  unset TYPE ID
  local TYPE ID
  for vv in ${VENDOR[*]} ; do
    local type=`echo "$1" | sed -n "/^${vv%.*}:[^:]*$/ s|:[^:]*$||g p"`
    if [ "$type" != "" ] ; then
      local id=`cat $VENDORLIST$type.txt | cut -f1 | grep -wn "${1##*:}" | cut -f1 -d":"`
      if [ "$id" != "" ] ; then TYPE=$type; ID=$id; break; fi
    fi
  done
  # echo $TYPE:$ID
  if [ "$ID" == "" ] ; then exit; fi
  local rawpar=`sed -n "${ID}p" "$VENDORLIST$TYPE.txt" | cut -f1 --complement`
  local two=`printf "$rawpar" | sed -n "s|\t\+|\n|g p" | sed -n "/^2=.*/ s|2=|| p"`
  local three=`printf "$rawpar" | sed -n "s|\t\+|\n|g p" | sed -n "/^3=.*/ s|3=|| p"`
  # echo 2: $two
  three=`sed -n 's/^"// ; s/"$// p' <<< $three`
  # echo 3: $three
  local str=
  for par in two three ; do
    if [ "$str" == "" ] ; then eval str='$'$par
    elif [ "`eval echo '$'$par`" != "" ] ; then eval str='$str\|$'$par
    fi
  done
  # echo "'$str'"
  local ouilist=`grep -Ew "$str" "$OUIFILE" | sed -n '/^[0-f][0-f]:[0-f][0-f]:[0-f][0-f]\t\+/ p' | cut -f1`
  random_oui $ouilist
}

function random_oui() {
  local line=`randnum 1 $#`
  eval printf '$'{$line}
}



# Main
if [[ $1 =~ ^(-)?(-)?(usage|help)$ ]] ; then
  usage_message
  exit
elif [[ $1 =~ ^(-)?(-)?(version)$ ]] ; then
  version_message
  exit
fi

if [ "$1" == "" ] ; then
  NIC=`random_part 6`
  OUI=`printf %x $(($((0x$(random_part 2)))&0xFE|0x02))`$(random_part 4) # ccccccUG
  echo ${OUI:0:2}:${OUI:2:2}:${OUI:4:2}:${NIC:0:2}:${NIC:2:2}:${NIC:4:2} | tr 'a-z' 'A-Z'
fi

while [ -n "$1" ] ; do
  case "$1" in
    -m)
      printf "`make_mac $2`"
      exit
      ;;
    -i)
      printf "`make_ven $2`"
      exit
      ;;
    -u) update_oui; exit ;;
    *) echo "Invalid mode: \"$1\"" ;;
  esac
  shift
done
