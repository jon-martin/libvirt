#!/usr/local/bin/perl
#
# Program to open the password file, read it in,
# print it, and close it again.

use strict;

my $output = "trident_cgroupstest.csv";
my $VM_OUTPUT = "/home/jon/libvirt/logs/logfile";

system("cgreate -g blkio,cpu,cpuacct,devices,freezer,memory,perf_event:/qemugroup");

for(my $i=1; $i<1005; $i++){
	system("nohup qemu-system-x86_64 -m 16 -hda serial_print.hda -name qemuVM-$i -no-kvm -nographic > $VM_OUTPUT$i.log &");
#        system("nohup qemu-system-x86_64 -m 16 -hda serial_print.hda -nographic > $VM_OUTPUT$i.log &");


	system("cgcreate -g blkio,cpu,cpuacct,devices,freezer,memory,perf_event:/qemugroup/qemuVM-$i");

	#Find PID
	sleep(1);
	system("ps aux | grep qemuVM-$i > PID.file");
	sleep(1);

	my $file = 'PID.file';		# Name the file
	open(INFO, $file);		# Open the file
	my @lines = <INFO>;		# Read it into an array
	close(INFO);			# Close the file

	my @firstline = split(/\s+/,$lines[0]);
	print $firstline[1];

	my $pid = $firstline[1];

	system("cgclassify -g blkio,cpu,cpuacct,devices,freezer,memory,perf_event:/qemugroup/qemuVM-$i $pid");
	print " - cgroups done\n";

        my $check ="";
        while ($check !~ /!/){
                sleep(1);                                       # Sleep for a while after creating the VM
                open FILE, "$VM_OUTPUT$i.log";                  # Open the file written by VM's serial output
		<FILE>;<FILE>;<FILE>;
                $check = <FILE>;                                # Store the first line written by VM
                close FILE;                                     # Close file
        }
	print "check done\n";
        # Check system status
        system("vmstat 3 2 > vmstat.tmp");              # Run vmstat over 10 seconds, while giving two sets of samples and write to file

        sleep(1);                                       # Short sleep before we open the file

        open(VMSTAT, "vmstat.tmp");                     # Open the newly written file
        <VMSTAT>; <VMSTAT>; <VMSTAT>;                   # Skip some header lines, and the first line showing data from boot
        my $vmstat = <VMSTAT>;                          # Store values
        chomp($vmstat);                                 # Format the vmstat data
        $vmstat =~ s/ +/ /g;
        $vmstat = trim($vmstat);
        my @values = split(/ +/,$vmstat);               # Split values into an array
        close (VMSTAT);

        # Retrieve time
        my $time = time;

        # Print results to file
        open (UUID, ">>$output");                 # Open uuid.lst and append new data
        print "$i $time $check $vmstat\n";      # Print to screen
        print UUID "$i $time $check $vmstat\n"; # Print to file
        if ($@) {                                       # Print extra if error occurs
                print "Error while creating domain:" . $@->message . "\n";
                print UUID "Error while creating domain:" . $@->message . "\n";
        }
        close (UUID);                                   # Close uuid.lst

}
sub trim($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}

print "\n done \n";
sleep 7200;
