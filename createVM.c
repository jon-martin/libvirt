
/* compile with: gcc -g -Wall "filename.c" -o "filename" -lvirt */
#include <stdio.h>
#include <stdlib.h>
#include <libvirt/libvirt.h>

int main(int argc, char *argv[])
{
    virConnectPtr conn;

    conn = virConnectOpen("qemu:///system");
    if (conn == NULL) {
        fprintf(stderr, "Failed to open connection to qemu:///system\n");
        return 1;
    }

  int i;

  for (i=0;i<100;i++) {
    char xml[1024];
    sprintf(xml,
"<domain type='qemu'> \
 <name>microMachine-%d</name> \
 <memory>16384</memory> \
 <vcpu>1</vcpu> \
 <os> \
  <type arch='i686' machine='pc-1.0'>hvm</type> \
  <boot dev='hd'/> \
 </os> \
 <devices> \
  <emulator>/usr/bin/kvm</emulator> \
  <disk type='file' device='disk'> \
   <driver name='qemu' type='raw'/> \
   <source file='/home/ubuntu/serial_print.hda'/> \
   <target dev='hda' bus='ide'/> \
   <address type='drive' controller='0' bus='0' unit='0'/> \
  </disk> \
  <serial type='file'> \
   <source path='/home/ubuntu/ouput%d.log'/> \
   <target port='1'/> \
  </serial> \
 </devices> \
</domain>", i, i);

    virDomainCreateXML(conn,xml,VIR_DOMAIN_NONE);
 }

    virConnectClose(conn);
    return 0;
}
