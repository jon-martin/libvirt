    /* example ex1.c */
    /* compile with: gcc -g -Wall ex1.c -o ex -lvirt */
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
     
        int i, j, ids[10];
        i = virConnectListDomains(conn, &ids[0], 10);
     
        for (j=0;j<i;j++) {
            printf("Domain %d\n", ids[j]);
        }
     
        char xml[] = \
    "<domain type='kvm' id='8'> \
    <name>microMachine-1</name> \
    <uuid>47205578-95AB-11E2-A27B-B3220CD1BD8E</uuid> \
    <memory>16384</memory> \
    <currentMemory>1</currentMemory> \
    <vcpu>1</vcpu> \
    <os> \
     <type arch='i686' machine='pc-1.0'>hvm</type> \
     <boot dev='hd'/> \
    </os> \
    <features> \
     <acpi/> \
     <apic/> \
     <pae/> \
    </features> \
    <clockoffset='utc'/> \
    <on_poweroff>destroy</on_poweroff> \
    <on_reboot>restart</on_reboot> \
    <on_crash>restart</on_crash> \
    <devices> \
     <emulator>/usr/bin/kvm</emulator> \
     <disk type='file' device='disk'> \
      <driver name='qemu' type='raw'/> \
      <source file='/home/jon/microMachine.hda'/> \
      <target dev='hda' bus='ide'/> \
      <address type='drive' controller='0' bus='0' unit='0'/> \
     </disk> \
     <controller type='ide' index='0'> \
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/> \
     </controller> \
     <serial type='file'> \
      <source path='/home/jon/ouput.log'/> \
      <target port='1'/> \
     </serial> \
     </devices> \
    </domain>";
     
     
    /*
        char xml[835] = "<domain type='kvm' id='1'><name>microMachine-$i</name><uuid>47205578-95AB-11E2-A27B-B3220CD1BD8E</uuid><memory>16384</memory><currentMemory>1</currentMemory><vcpu>1</vcpu><os><type arch='i686' machine='pc-1.0'>hvm</type><boot dev='hd'/></os><features><acpi/><apic/><pae/></features><clockoffset='utc'/><on_poweroff>destroy</on_poweroff><on_reboot>restart</on_reboot><on_crash>restart</on_crash><devices><emulator>/usr/bin/kvm</emulator><disk type='file' device='disk'><driver name='qemu' type='raw'/><source file='$VM_HDA'/><target dev='hda' bus='ide'/><address type='drive' controller='0' bus='0' unit='0'/></disk><controller type='ide' index='0'><address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/></controller><serial type='file'><source path='$VM_OUTPUT$i.log'/><target port='1'/></serial></devices></domain>";
        char xml[912] = "<domain type='kvm' id='8'> <name>microMachine-1</name> <uuid>47205578-95AB-11E2-A27B-B3220CD1BD8E</uuid> <memory>16384</memory> <currentMemory>1</currentMemory> <vcpu>1</vcpu> <os>  <type arch='i686'machine='pc-1.0'>hvm</type>  <boot dev='hd'/> </os> <features>  <acpi/>  <apic/>  <pae/> </features> <clockoffset='utc'/> <on_poweroff>destroy</on_poweroff> <on_reboot>restart</on_reboot> <on_crash>restart</on_crash> <devices>  <emulator>/usr/bin/kvm</emulator>  <disk type='file' device='disk'>   <driver name='qemu' type='raw'/>  <source file='/home/jon/microMachine.hda'/>   <target dev='hda' bus='ide'/>   <address type='drive' controller='0'bus='0' unit='0'/>  </disk>  <controller type='ide' index='0'>   <address type='pci' domain='0x0000'bus='0x00' slot='0x01' function='0x1'/>  </controller>  <serial type='file'>   <sourcepath='/home/jon/ouput.log'/>   <target port='1'/>  </serial>  </devices></domain>";
    */
     
        virDomainCreateXML(conn,xml,VIR_DOMAIN_NONE);
     
        virConnectClose(conn);
        return 0;
    }

