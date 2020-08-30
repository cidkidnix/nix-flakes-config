#!/bin/sh

device_addr="0000:29:00.0"
#device_addr=$1

if [ ! -d "/sys/bus/pci/devices/${device_addr}" ]; then
  echo "PCI device $device_addr not found"
  exit 1
fi

# we don't try to replicate amdgpu logic for checking wether reset is applicable
# instead we require that device is initially bound to amdgpu and assume that after unbind it's applicable
if [ $(readlink -f "/sys/bus/pci/devices/${device_addr}/driver") != "/sys/bus/pci/drivers/amdgpu" ]; then
  echo "PCI device $device_addr is not bound to amdgpu driver"
  exit 1
fi

card_node=$(readlink -f "/dev/dri/by-path/pci-${device_addr}-card")
render_node=$(readlink -f "/dev/dri/by-path/pci-${device_addr}-render")

echo "Removing device nodes to prevent futher userspace access..."
rm "$card_node" "$render_node"

echo "Terminating processes accessing device to prevent unbind issue..."
pids=$(for fd in /proc/*/fd/*; do
  fd_target=$(readlink "$fd")
  if [ "$fd_target" = "$card_node (deleted)" ] || [ "$fd_target" = "$render_node (deleted)" ]; then
    echo $fd;
  fi;
done|cut -d'/' -f3|sort|uniq|paste -sd " " -)
if [ ! -z "$pids" ]; then
  echo " PIDs: $pids"
  # must not continue until processes are terminated
  while true; do
    kill $pids 2>/dev/null
    # 0 or 64 mean some processes were sent signal just now
    if [ $? -eq 1 ]; then
      break
    fi
    sleep 1
  done
fi

echo "Unbinding from amdgpu driver..."
echo "$device_addr" > "/sys/bus/pci/drivers/amdgpu/unbind"
while [ $(readlink -f "/sys/bus/pci/devices/${device_addr}/driver") = "/sys/bus/pci/drivers/amdgpu" ]; do
  sleep 1
done

echo "Resetting..."
# vendor specific reset via writing magic number to register which is not meant for writing anything
setpci -s "$device_addr" 7c.l=39d5e86b || exit 1
# qemu Bonaire reset quirk reads from MMIO reg to make sure we're out of reset
sleep 1
