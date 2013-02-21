#! /usr/bin/perl

use strict;
use Sys::Virt;
use Data::UUID;
use Getopt::Std;

my $opt_string = 'hn:';
my %opt;
my $NUMBER;
my $ug = new Data::UUID;
my $idleValue = 100;

my $VM_OUTPUT = "/home/jon/output/virsh";
my $VM_HDA = "/home/jon/Documents/scripts/serial_print_char_then_idle.hda";

getopts("$opt_string", \%opt ) or usage();
usage() if $opt{h};

$NUMBER = $opt{'n'};

my $uri = "qemu:///system"; my $vmm; eval {
$vmm = Sys::Virt->new(uri => $uri); }; if ($@) {
        print STDERR "Unable to open connection to $uri" . $@->message . "\n";
        print "Unable to open connection to $uri" . $@->message . "\n";
}

for (my $i=1; $i<=$NUMBER; $i++){
	my $uuid = $ug->to_string($ug->create());	# Create UUID

	my $xml = " 
<domain type='qemu' id='5'>
  <name>microMachine-$i</name>
  <uuid>$uuid</uuid>
  <memory>66560</memory>
  <currentMemory>1</currentMemory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64' machine='pc-1.0'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <video>
      <model type='cirrus' vram='9216' heads='1'/>
    </video>
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw'/>
      <source file='$VM_HDA'/>
      <target dev='hda' bus='ide'/>
      <address type='drive' controller='0' bus='0' unit='0'/>
    </disk>
    <controller type='ide' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
    </controller>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </memballoon>
    <serial type='file'>
      <source path='$VM_OUTPUT$i.log'/>
      <target port='1'/>
    </serial>
  </devices> 
</domain> "; 

	my $dom = $vmm->create_domain($xml);		# Create VM based on XML data

	sleep(5);					# Sleep for a while after creating the VM
	
	# Check written file
	open FILE, "$VM_OUTPUT$i.log";			# Open the file written by VM's serial output
	my $check =  <FILE>;				# Store the first line written by VM
	close FILE;					# Close file

	# Check system status
	system("vmstat 5 2 > vmstat.tmp");		# Run vmstat over 10 seconds, while giving two sets of samples and write to file
	open(VMSTAT, "vmstat.tmp");			# Open the newly written file
	<VMSTAT>; <VMSTAT>; <VMSTAT>;			# Skip some header lines, and the first line showing data from boot
	my $vmstat = <VMSTAT>;				# Store values
	my @values = split(/ +/,$vmstat);		# Split values into an array

	# Print results to file
	open (UUID, '>>uuid.lst');			# Open uuid.lst and append new data
	print "$i\t$uuid\t$check\t$vmstat";		# Print to screen
	print UUID "$i\t$uuid\t$check\t$vmstat";	# Print to file
	close (UUID);					# Close uuid.lst

	# CPU idle value
	$idleValue = $values[15];			# Retrieve the CPU idle value

	if ($idleValue == 0){				# If the CPU idle time is 0, stop
		die;
	}
}

sub usage(){
        print "helpmethod\n";
        exit 0;
}

exit 0
