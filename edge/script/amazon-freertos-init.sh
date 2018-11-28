#! /bin/bash

prefix=$1
if test -z "$prefix"; then
  thing_agg=gateway-ultra96
  thing_afr=node-zynq7k
else
  thing_agg=${prefix}-gateway-ultra96
  thing_afr=${prefix}-node-zynq7k
fi

cd $(dirname $0)
dc_afr=$(dirname $0)/../../edge/auth-${thing_afr}

aws iot describe-endpoint --output text > $dc_afr/ggconfig.txt
echo ${prefix} >> ${dc_afr}/ggconfig.txt

lsblk -lnp --output NAME,RM,FSTYPE,SIZE > /tmp/out

# Amazon FreeRTOS needs certificates to be provisioned in DER format.
openssl x509 -outform der -in ${dc_afr}/${thing_afr}.crt.pem -out ${dc_afr}/${thing_afr}.crt.der
openssl rsa -outform der -in ${dc_afr}/${thing_afr}.key.prv.pem -out ${dc_afr}/${thing_afr}.key.prv.der

found=0
while read -r line; do
  dev=$(echo $line   | tr -s ' ' ' ' | cut -f1 -d' ')
  is_rm=$(echo $line | tr -s ' ' ' ' | cut -f2 -d' ')
  fs=$(echo $line    | tr -s ' ' ' ' | cut -f3 -d' ')
  sz=$(echo $line    | tr -s ' ' ' ' | cut -f4 -d' ')

  if test "$is_rm" == 1 && test "$fs" == "vfat" && (test "$sz" == "7.4G" || test "$sz" == "7.3G"); then
    found=1
    break
  fi
done < /tmp/out

if test "$found" == "0"; then
  echo microSD not found. Check that it has been properly inserted.
  exit 1
fi

echo Need to mount filesystem, enter password \'xilinx\' if requested.
#right now, image doesn't have mkfs.vfat so... we hope
#sudo mkfs -t vfat ${dev}
sudo mount $dev /media
sudo cp $(dirname $0)/../sd_card/BOOT.bin /media
sudo cp ${dc_afr}/${thing_afr}.crt.der /media
sudo cp ${dc_afr}/${thing_afr}.key.prv.der /media
sudo cp ${dc_afr}/ggconfig.txt /media
sudo ls -l /media
sudo umount /media
echo microSD now unmounted. Remove and insert microSD to the MicroZED board.
