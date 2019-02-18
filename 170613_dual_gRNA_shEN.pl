#!/usr/bin/perl -w
##########################################################################################
# name:			/Users/cory/Church/Scripts_Church/																 
# date:   		2017-3-14																 
# author:  		Cory Smith																 
# description: 																			
# usage: 		
##########################################################################################

use strict;
use Cwd;

#---------------------------------------------------------------------------------------#
my $start=(times)[0];			# save the start time
#---------------------------------------------------------------------------------------#

our($opt_i); # set up global variables for Getopt
get_args();			# get the command line arguments 

#print "$opt_i\n";

###################################
# get input files #
###################################

my @fastq = @{get_fastq($opt_i)};

#foreach(@fastq){print "$_\n";}
#print "$fastq[0]\n";


####################################
# Generate Report File and Headers #
####################################

# build index
my $outscript="$opt_i/dual_gRNA.txt";

#open(REPORT, ">$outscript");
print "Sample\tTotal Reads\tWhole Reads\tDual Cut Reads\n";

foreach(@fastq){
	#print "$_\n";
	dual_gRNA($_);
}

#close(REPORT);
#print "\n\t\t\t\t$outscript\n\n";



#=====================================================#
#================== END Main Script ==================#
#=====================================================#


###############################################################
# get_args parses the commandline arguments using Getopt::Std #
###############################################################


#---------------------------------------------------------------------------------------#
sub dual_gRNA{
	my $fastq=shift @_;
	$fastq=~/(\S+)_R1\.fastq/;
	my $basefastq=$1;
	#print "$fastq\n";
	
	my $shEN_left="AATGAAGG";
	my $shEN_right="ATGAAGGC";
	my $shEN_third="TTGAAACC";

	my $full_left="TAGTTGGA";
	my $full_right="CCTCAGCA";


	#my %breakpoint;
	my %fulllength;

	open(FASTQ, "$opt_i/$fastq");

	my $rowcount=0;
	my $totalreadcount=0;
	my $cutreadcount=0;
	my $wholereadcount=0;

	while (<FASTQ>){
		#print "$a\n";
		if ($rowcount==1){
			$totalreadcount++;
			if ($_=~/$shEN_left/ or $_=~/$shEN_right/ or $_=~/$shEN_third/){
				$cutreadcount++;
				#$breakpoint{$1}++;
			}	
			elsif($_=~/$full_left/ or $_=~/$full_right/){
				$wholereadcount++;
			}
		}
		$rowcount++;
		if ($rowcount==4){
			$rowcount=0;
		}
	}

	print "$basefastq\t$totalreadcount\t$wholereadcount\t$cutreadcount\n";
	close(FASTQ);
	
}
#---------------------------------------------------------------------------------------#


###############################################################
# get_args parses the commandline arguments using Getopt::Std #
###############################################################


#---------------------------------------------------------------------------------------#
sub get_args{
	use Getopt::Std;
	
	# set in main script:
	# our($opt_i); # set up global variables for Getopt
	# -i = input directory

	getopt('i');		# return variables following -i -b -l
	
	if (!defined $opt_i) {$opt_i=getcwd()}	
}
#---------------------------------------------------------------------------------------#

#---------------------------------------------------------------------------------------#
sub get_fastq {
	my @inputFastq;
	my $dir=shift @_;
	opendir(DIR, $dir) or die $!;
	while (my $file = readdir(DIR)) {
		next unless (-f "$dir/$file");
		if ($file !~ /^\./ & $file =~ /R1.fastq$/) {
    		push(@inputFastq, $file);
    	}
	}
	return \@inputFastq;
	
}
#---------------------------------------------------------------------------------------#




################################################
# Calculate and print execution time of script #
################################################

my $end=(times)[0];			# save the end time
my $dt =$end-$start;		# difference is the execution time
print STDERR "Execution time = $dt seconds\n"; # outputs to STDERR