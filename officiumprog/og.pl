#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office
#generates offices using K1570 kalendaR

package horas;
#1;

#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FATAL=>qw(all);

use POSIX;
use FindBin qw($Bin);
use File::Basename;

@ftab = ('none','Simplex','Semiduplex','Duplex','Duplex majus',
  'Duplex II class','Duplex I class','Duplex I class');

open (INP, "../../www/horas/Latin/Tabulae/K1570.txt") or die "Latin/Tabulae/K1570.txt cannot open for input!";
@a = <INP>;
close INP;

$i = 0;
while (1 == 1) {
  if ($i >= @a) {last;}
  $line = $a[$i];
  $i++;	
  if (!$line || length($line) < 3 || $line !~ /\=[0-9]+\-[0-9]+o\=/i) {next;}

  @line = split('=', $line);
  $com = ($line =~ /vigil/i) ? 'C1a' : ($line =~ /apostle/i) ? 'C1' : 
    ($line =~ /martyrs/i) ? 'C3' : 
    ($line =~ /Virgin Mary/i) ? 'C11' : ($line =~ /virgin/i) ? 'C6' :
    ($line =~ /doctor/i) ? 'C4a' : ($line =~ /(bishop|pope)/i) ? 'C4' :
    ($line =~ /(S\.|Ss\.)/) ? 'C5' : '';
    $commune = '';
    if ($com) {$commune = "vide $com";}
  
  $rank = $line[3];
  if ($rank == 1) {$rank = 1.1;}
  $str = "[Rank]\n$line[2];;$ftab[$rank];;$rank;;" . $commune . "\n\n[Rule]\n"; 
  if ($commune) {$str .= "$commune;\n";}

  if ($com =~ /C1a/i) {$str .= "Responsory Feria\nPreces feriales\nVersum Feria\n\n";}
  elsif ($rank >= 2) {$str .= "9 lectiones\n\n"; }

  for $dir ('Latin', 'English', 'Magyar') {
	  open (OUT, ">../../www/horas/$dir/Sancti/$line[1].txt") or die "$dir/Sancti/$line[1].txt cannot open for output";
    print OUT $str;
    close OUT;
  }
  next;
}


