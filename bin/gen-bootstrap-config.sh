#!/bin/zsh
# -*- mode: sh; tab-width: 2 -*- *


# quick and dirty script to generate the bare minimum configurations to use
# with IOS XRv hosts using the Cisco Virtual Appliance Configuration (CVAC)
# tools.


START=$1
END=$2

HOST_PREFIX="r"
CONF_DIR=${HOME}/tmp/isos
OUTPUT_DIR=${HOME}

#-------------------------------------------------------------------------------
# functions
#
gen_config() {
  local CONFIG ROUTER RID;
  CONFIG=$1 ROUTER=$2 RID=$3;

  cat <<EOF > ${CONFIG}
hostname ${ROUTER}
ipv4 netmask-format bit-count
telnet vrf default ipv4 server max-servers 10
line default
 exec-timeout 0 0
!
interface MgmtEth0/0/CPU0/0
 description management interface -> br100
 ipv4 address 192.168.200.${RID}/24
 no shutdown
!
EOF
}


gen_iso() {
  #
  local CONFIG ROUTER ODIR;
  ODIR=$1 CONFIG=$2 ROUTER=$3

  mkisofs -o ${ODIR}/${RTR}.iso -l --iso-level 2 ${CONFIG}
}


seq () {
  local lower upper output;
  lower=$1 upper=$2;
  while [ $lower -le $upper ];
  do
    output="$output $lower";
    lower=$[ $lower + 1 ];
  done;
  echo $output
}



foreach i (`seq $START $END`)
  RTR="${HOST_PREFIX}$i"
  CONFIG_PATH="${CONF_DIR}/${HOST_PREF}${RTR}"

  # check for the presence of the config directory
  if [[ -d  ${CONFIG_PATH} ]];
  then
    gen_config ${CONFIG_PATH}/iosxr_config.txt ${RTR} $i;
    gen_iso  ${OUTPUT_DIR} ${CONFIG_PATH}/iosxr_config.txt ${RTR};
  else
    # make the directory tree
    mkdir -p ${CONFIG_PATH};
    gen_config ${CONFIG_PATH}/iosxr_config.txt ${RTR} $i;
    gen_iso  ${OUTPUT_DIR} ${CONFIG_PATH}/iosxr_config.txt ${RTR};
  fi
end
