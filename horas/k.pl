#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office

package horas;
#1;

#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FATAL=>qw(all);

use POSIX;
use FindBin qw($Bin);
use File::Basename;

@ftab = ('none','Simplex','Duplex optional','Duplex memorial','Duplex memorial',
  'Douplex feast','Duplex solemnity','Duplex solemnity');

open (INP, "Latin/Psalterium/K2009.txt") or die "Latin/Psalterium/K2009.txt cannot open for input!";
@a = <INP>;
close INP;

$i = 0;
while (1 == 1) {
  if ($i >= @a) {last;}
  $line = $a[$i];
  $i++;	
  if (!$line || length($line) < 3 || $line !~ /\=[0-9]+\-[0-9]+n\=/i) {next;}

  @line = split('=', $line);
  $commune = ($line =~ /apostle/i) ? 'C1' : ($line =~ /martyrs/i) ? 'C3' : 
    ($line =~ /Virgin Mary/i) ? 'C11' : ($line =~ /virgin/i) ? 'C6' :
    ($line =~ /doctor/i) ? 'C4a' : ($line =~ /(bishop|pope)/i) ? 'C4' :
    ($line =~ /(S\.|Ss\.)/) ? 'C5' : '';
    if ($commune) {$commune = "vide $commune";}
  
  $str = "[Rank]\n$line[2];;$ftab[$line[3]];;$line[3];;" . $commune . "\n\n[Rule]\n"; 
  if ($commune) {$str .= "$commune;\n";}

  for $dir ('Latin', 'English', 'Magyar') {
	open (OUT, ">$dir/Sancti/$line[1].txt") or die "$dir/Sancti/$line[1].txt cannot open for output";
    print OUT $str;
    close OUT;
  }
  next;
}


