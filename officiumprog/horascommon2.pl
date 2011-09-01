#!/usr/bin/perl

#αινσφυϊόϋΑΙ
# Name : Laszlo Kiss
# Date : 01-25-08
# horas common files to reconcile tempora & sancti

#use warnings;
#use strict "refs";
#use strict "subs";
my $a = 4;

sub error {
  my $t = shift;
  $error .= "=$t=<BR>";
}

#*** getweek($flag)
# returns $week string list using date1 = mm-dd-yyy string as parameter
# set $dayofweek
# next day if $flag
sub getweek {
   my $flag = shift;              
   my $daysec = 60 * 60 * 24;
                                   
   my $t = timelocal(0,0,12,$date1[1],$date1[0]-1,$year);
   if ($flag) {$t += $daysec;}  
   @d = localtime($t);
   if (!$flag) {$dayofweek = $d[6];}
   else {$nextdayofweek = $d[6];}
   my $advent1 = getadvent($year);

   my $y = $d[5]+1;
   my $dy = $flag ? $nextdayofweek : $dayofweek;
                      
   #Advent in december
   if ($t >= $advent1) {      
     if ($t < ($advent1 + 28 * $daysec)) {
	     $n = 1 + floor(($t - $advent1) / (7 * $daysec));
       if ($month == 11 || $day < 25) {return getname("Adv$n");}
	   }
     return '';
   }

   if ($month == 1 && $day  < 7) {return '';}

   my $ordtime = timelocal(0,0,12,6,0,$year);
   @ot = localtime($ordtime);     
   $ordtime += (7 - $ot[6]) * $daysec;
                                                 
   my $easter = timelocal(0,0,12,geteaster($year));   
   
   if ($t < $easter - 63 * $daysec) {
      $n = floor(($t - $ordtime) / (7 * $daysec)) + 1;  
	    return getname("Epi$n");
   }
   
   if ($t < $easter - 56 * $daysec) {return getname("Quadp1");}
   if ($t < $easter - 49 * $daysec) {return getname("Quadp2");}
   if ($t < $easter - 42 * $daysec) {return getname("Quadp3");}
   
   if ($t < ($easter)) {
 	    $n = 1 + floor(($t - ($easter - 42 * $daysec)) / (7 * $daysec));
		return getname("Quad$n");
   }

   if ($t < ($easter + 56 * $daysec)) {
     $n = floor(($t - $easter) / (7 * $daysec)); 
	   return getname("Pasc$n");
   }
   

   $n = floor(($t - ($easter + 49 * $daysec)) / (7 * $daysec));  

   if ($n < 24) {return getname(sprintf("Pent%02i", $n));}
   #my $wdist = floor(($advent1 - $t + 3600) / (7 * $daysec));
   my $wdist = floor(($advent1 - $t + 6 * $daysec) / (7 * $daysec));
   if ($wdist < 2) {return "Pent24";}
   return sprintf("Epi%1i", 8 - $wdist);

}

#*** getname($abr)
# returns the name from the abbreviation
sub getname {
  my $abbr = shift;
  my @days = ('Dominica','Feria II','Feria III','Feria IV','Feria V','Feria VI','Sabbato');

  if (!@sundaytable) {getsundaytable();}
  my $i = 0;
  for ($i = 0; $i < @sundaytable; $i++) {
    my $str = chompd($sundaytable[$i]);
    if ($str && $str =~ /^$abbr\=(.+)/) {
	  $str = $1;
	  if ($str =~ /^\s*\*/) {return "$abbr = $'";}
	  if ($d[6] == 0) {return "$abbr = Dominica $str";}
	  if ($str =~ /infra/i) {return "$abbr = $days[$dayofweek] $str";}
	  return "$abbr=$days[$dayofweek] infra Hebdomodam $str";
	}
  }
  return "$abbr not found";
}

#*** getsundaytable()
# reads sundaytable.txt into @sundaytable
sub getsundaytable {
   if (open (NI, "$datafolder/sundaytable.txt")) {
     @sundaytable = <NI>;
	 close NI;
   }
}

#*** getadvent($year)
# return time for the first sunday of advent in the given year
sub getadvent {
  my $year = shift;
  my $daysec = 60 * 60 * 24;
  my $christmas = timelocal(0,0,12,25,11,$year);
  my @ch = localtime($christmas); 
  my $n = ($ch[6] == 0) ? 7 : $ch[6]; #days between Christmas and 4th Sunday of Advent
  return $christmas - ($n + 21) * $daysec; #1st Sunday of Advent
}

#*** geteaster(year)
# returns easter date (dd,mm,yyyy);
sub geteaster {
  my $year = shift;

  my $c = floor($year / 100);
  my $n = $year - 19 * floor( $year / 19 );
  my $k = floor(( $c - 17 ) / 25);
  my $i = $c - floor($c / 4) - floor(( $c - $k ) / 3) + 19 * $n + 15;
  $i = $i - 30 * floor($i / 30 );
  $i = $i - floor( $i / 28 ) * ( 1 - floor( $i / 28 ) * floor( 29 / ( $i + 1 )) )
        * floor( ( 21 - $n ) / 11 );
  my $j = $year + floor($year / 4) + $i + 2 - $c + floor($c / 4);
  $j = $j - 7 * floor( $j / 7 );     
  my $l = $i - $j;
  my $m = 3 + floor(( $l + 40 ) / 44);
  my $d = $l + 28 - 31 * floor( $m / 4 );
  return ($d, $m-1, $year);
}

#*** checkfile($lang, $filename) 
# substitutes English if no $lang item, Latin if no English
sub checkfile {
  my $lang = shift;
  my $file = shift;
                             
  if (-e "$datafolder/$lang/$file") {return "$datafolder/$lang/$file";}
  elsif ($lang =~ /english/i) {return "$datafolder/Latin/$file";}
  elsif (-e "$datafolder/English/$file") {return "$datafolder/English/$file";}
  else {return "$datafolder/Latin/$file";}
}

#*** getrank() loads files from tempora and sancti
sub getrank {
  my $c = $dialog{'communes'};
  $c =~ s/\n//sg;
  %communesname = split(',', $c);
  $dayname[0] =~ s/\s*$//g;
  $dayname[0] =~ s /^\s*//g;

  my %tempora = {};
  my %saint = {};
  my $trank = '';
  my $tname = '';
  my $srank = '';
  my $sname = '';
  my $cname = ''; 

  my @trank = ();
  my @srank = ();

  my $kalendarname = ($version =~ /1570/) ? 1570 : ($version =~ /Trident/i) ? 1888 
    : ($version =~ /1960/) ? 1960 : 1942;     
  our %kalendar = undef;
  our $kalendarkey = '';
  if (open(INP, "$datafolder/Latin/Psalterium/K$kalendarname.txt")) {
    my @a = <INP>;
    close INP;
    foreach (@a) {
      my @item = split('=', $_); 
      $kalendar{$item[0]} = $item[1];
    }
  } else {error("$datafolder/Latin/Psalterium/$kalendarname.txt cannot open");}


  my $sday = get_sday($month, $day, $year);  

  # Handle transfers
  if ($version =~ /(1955|1960)/ && open(INP, "$datafolder/Latin/Psalterium/Tr1960.txt")) {
     my $tr = '';
     while ($line = <INP>) {$tr .= chompd($line);}
     $tr =~ s/\=/\;\;/g;
     %transfer1960 = split(';;', $tr);      
     $transfer1960 = $transfer1960{$sday}; 
  } else {%transfer1960 = {}; $transfer1960 = '';} 
  if ($transfer1960 && $transfer1960 !~ /tempora/i) {$transfer1960 = "Sancti/$transfer1960";} 


  if ($version =~ /Trid/i && open(INP, "$datafolder/Latin/Psalterium/TrTrid.txt")) {
     my $tr = '';
     while ($line = <INP>) {$tr .= chompd($line);}
     $tr =~ s/\=/\;\;/g;
     %transferTrid = split(';;', $tr);      
     $transferTrid = $transferTrid{$sday}; 
  } else {%transferTrid = {}; $transferTrid = '';} 
  if ($transferTrid && $transferTrid !~ /tempora/i) {$transferTrid = "Sancti/$transferTrid";} 

  
  my $v = ($version =~ /(1955|1960)/) ? '1960' : ($version =~ /Trid/i) ? 'Trid' : '';   
  if (open(INP, "$datafolder/Latin/Psalterium/Tr$v$year.txt")) {
     my $tr = '';
     while ($line = <INP>) {$tr .= chompd($line);}
     $tr =~ s/\=/\;\;/g;   
     %transfer = split(';;', $tr);      
  } else {%transfer = {}; }
  $transfer = $transfer{$sday};  
  if ($transfer && $transfer !~ /tempora/i) {$transfer = "Sancti/$transfer";} 
                
  $vespera = 3;
  $svesp = 3;
  $tvesp = 3;
  $cvespera = 0;
  my $tn = '';
  if ($dayname[0]) {
    $tn = "Tempora/$dayname[0]-$dayofweek";    
    if ($version =~ /(1955|1960)/ && exists($transfer1960{$tn})) {$tn =$transfer1960{$tn};}
    elsif($version =~ /Trid/i && exists($transferTrid{$tn})) {$tn = $transferTrid{$tn};}
  } 
  
  if ($version =~ /(1955|1960)/ && exists($transfer1960{$sday}) &&
    $transfer1960{$sday} =~ /tempora/i) {$tn = $transfer1960{$sday};}
  elsif ($version =~ /Trid/ && exists($transferTrid{$sday}) &&
    $transferTrid{$sday} =~ /tempora/i) {$tn = $transferTrid{$sday};}
  if (exists($transfer{$sday}) && $transfer{$sday} =~ /tempora/i) {$tn = $transfer{$sday};}
               
  my $nday = nextday($month, $day, $year); 
  if ($hora =~ /(vespera|Completorium)/i) {
    if ($version =~ /(1955|1960)/ && $transfer1960{$nday} =~ /tempora/i) 
      {$tn  = $transfer1960{$nday};}
    elsif ($version =~ /Trid/i && $transferTrid{$nday} =~ /tempora/i) 
      {$tn  = $transferTrid{$nday};}
    if ($transfer{$nday} =~ /tempora/i) {$tn = $transfer{$nday};}
  }
  if ($testmode =~ /(Saint|Common)/i) {$tn = 'none';}
					  
  $tn1 = '';
  $tn1rank = '';
                              
  #Vespera anticipation  concurrence
  if (-e "$datafolder/$lang1/$tn.txt" || $dayname[0] =~ /Epi0/i) {  
     $dofw = $dayofweek;
     if ($hora =~ /(vespera|completorium)/i) {      
       my $a = getweek(1);            
       my @a = split('=', $a); 
       $dn[0] = $a[0];
       $dn[0] =~ s/\s*$//g;
       $dn[0] =~ s/^\s*//g;
       $dofw = ($dayofweek + 1) % 7;
       $tn1 = "Tempora/$dn[0]-$dofw";    
       if ($version =~ /(1955|1960)/ && exists($transfer1960{$tn1})) {$tn1 =$transfer1960{$tn};}
       elsif($version =~ /Trid/i && exists($transferTrid{$tn1})) {$tn1 = $transferTrid{$tn1};}

       %tn1 = %{officestring("$datafolder/$lang1/$tn1.txt", 1)};
       if ($tn1{Rank} =~ /(Feria|Vigilia|infra octavam)/i  && $tn1{Rank} !~ /in octava/i) 
         {$tn1rank = '';}
       elsif ($version =~ /1960/ && $tn1{Rank} =~ /Dominica Resurrectionis/i) 
	       {$tn1rank = '';}
       elsif ($version =~ /1960/ && $tn1{Rank} =~ /Patrocinii St. Joseph/i) 
  	     {$tn1rank = '';}

	   else {$tn1rank = $tn1{Rank};}	
     }
	   
     $tname = "$tn.txt";          
                       
     %tempora = %{officestring("$datafolder/$lang1/$tname")};   
     $trank = $tempora{Rank};
  } else {$trank = ''; $tname = '';}      

  @trank = split(";;", $trank);  
  @tn1 = split(';;', $tn1rank);   
  if ($tn1[2] > $trank[2]) {  
    $tname = "$tn1.txt";
    %tempora = %tn1; 
    $trank = $tempora{Rank}; 
    @trank = split(";;", $trank);  	
    $dayname[0] = $dn[0];
	  $tvesp = 1;
    $tcommemorated = $trank[0];
  } elsif (!$trank) {
    $tname = '';
    %tempora = {};
  }
                            
  #handle sancti
  my $sn = "Sancti/$kalendar{$sday}";     
  if ($transfer1960 =~ /Sancti/) {$sn = $transfer1960;}   
  elsif ($transferTrid =~ /Sancti/) {$sn = $transferTrid;}
  if ($transfer =~ /Sancti/) {$sn = $transfer;;}     
  
  if ($testmode =~ /^Season$/i) {$sn = 'none';}  
  if (-e "$datafolder/$lang1/$sn.txt") {  
     $sname = "$sn.txt";          

     %saint = updaterank(setupstring("$datafolder/$lang1/$sname"));
     $srank = $saint{Rank};    
  
  } else {$srank = '';}                 

  if ($version =~ /(1955|1960)/) {
    if ($srank =~ /vigil/i && $sday !~ /(06\-23|06\-28|08\-09|08\-14|12\-24)/) {$srank = '';}
    if ($srank =~ /(infra octavam|in octava)/i) {$srank = '';}  
  } #else {if ($srank =~ /Simplex/i) {$srank = '';}}

  @srank = split(";;", $srank);      
  if ($srank[2] < 2 && $hora =~ /(vespera|completorium)/i) {$srank = ''; @srank = undef;}
  if ($trank[2] >= 6 && $srank[2] < 6) {$srank = ''; @srank = undef;}
                                                               
  if ($version =~ /1955/ && $srank[2] == 2 && $srank[1] =~ /Semiduplex/i) 
    {$srank[2] = 1.5;}  #1955: semiduplex reduced to simplex
  if ($version =~ /1960/ && $srank[2] < 2 && $srank[1] =~ /Simplex/i) 
    {$srank[2] = 1;}
  if (transfered($sday)) {$srank[2] = 0;}         
                               
  #check for concurrence
  my $cday = $crank = '';
  my %csaint = {};
  my $crank = '';
  my $vflag = 0; 
  if ($hora =~ /(vespera|completorium)/i) {     
    $ocday = $cday = nextday($month, $day, $year);  
    if (exists($transfer1960{$cday})) {$cday = $transfer1960{$cday};}
    elsif (exists($transferTrid{$cday})) {$cday = $transferTrid{$cday};}
    if (exists($transfer{$cday})) {$cday = $transfer{$cday};}
                                                    
    $cday = "$kalendar{$cday}"; 
    if ($cday && $cday !~ /tempora/i) {$cday = "Sancti/$cday";} 
    if ($testmode =~ /^Season$/i) {$cday = 'none';} 	   

	  if (!transfered($ocday) && -e "$datafolder/$lang1/$cday.txt") {  
      $cname = "$cday.txt";             
      %csaint = updaterank(setupstring("$datafolder/$lang1/$cname"));
      $crank = ($csaint{Rank} =~ /vigilia/i) ? '' : $csaint{Rank};  
    }

    if ($version =~ /(1955|1960)/) {
      if ($crank =~ /vigil/i && $sday !~ /(06\-23|06\-28|08\-09|08\-14|08\-24)/) {$crank = '';}
      if ($crank =~ /octav/i && $crank !~ /cum Octav/i) {$crank = '';}
    }
	if ($csaint{Rule} =~ /No prima vespera/i) {$crank = '';}
                                           
    if ($crank =~ /infra octav/i) {$crank = '';} 
    if ($srank =~ /vigilia/i) {$srank[2] = 0; $srank = '';}
    @crank = split(";;", $crank);    
                                         
    if (($version =~ /1955/ && $crank[2] < 5) || ($version =~ /1960/ && $crank[2] < 6) ) 
	  {$crank = ''; @crank = splice(@crank, @crank);}    
	                                                   
	if ($crank[2] >= $srank[2] && $crank[2] > 1) {     
	  ($cname, $sname) = ($sname, $cname);
	  ($crank, $srank) = ($srank, $crank);	  
	  $svesp = 1;
      #switched
	  (%saint, %csaint) = (%csaint, %saint);
      @srank = split(";;", $srank);
      @crank = split(";;", $crank); 
		  $vflag = 1;
      $ccommemorated = $crank[0];  	
      if ($crank =~ /infra octav/i) {$crank = ''; $cname = ''; %csaint = undef; @crank = ''; $commemorated = '';} 
    
    } elsif ($crank[2] > 1) {$ccommemorated = $crank[0];}  
                         
  } 
		 
  $commemoratio = $commemoratio1 = $commemorated = $communetype = $commune = 
    $dayname[2] = $scriptura = '';
  $comrank = 0;			 
  
  if ($version =~ /Trid/i && $trank[2] < 5.1 && $trank[0] =~ /Dominica/i) 
    {$trank[2] = 2.9;}   
  if ($version =~ /1960/ && (floor($trank[2]) == 3 || $dayname[0] =~ /Quad[0-9]/i || 
    ($dayname[0] =~ /quadp3/i && $dayofweek > 3)) && $srank[2] < 5) {$trank[2] = 4.9;}
  if ($version =~ /1960/ && $dayofweek == 0) {
    if (($trank[2] >= 6 && $srank[2] < 6) || ($trank[2] >= 5 && $srank[2] < 5)) 
	  {$srank = ''; @srank = undef;}
  }
  
  #if ($svesp == 3 && $srank[2] >= 5 && $dayofweek == 6) {$srank[2] += 5;}  ?????????

  #Winner is a saint (> or >= ???)
  if (($srank[2] && ($srank[2] > $trank[2] && ($dayofweek != 6 || $srank[2] >= 2)) || !$trank[2]) || 
    ($vflag && ($srank[2] >= $trank[2] && ($srank[2] > 1 && $srank[2] < 5 && $dayofweek != 5) ||
    ($dayofweek == 0 && $srank[2] >= 5)))
    || ($version =~ /1960/ && $dayofweek == 6 && $srank[2] >= 5 && $trank[2] < 6)) {     
    $rank = $srank[2];              
	  $dayname[1] = "$srank[0] $srank[1]";
    $winner = $sname;
    %winner = %{setupstring("$datafolder/$lang1/$winner")};     
    $vespera = $svesp;
    if ($srank[3] =~ /^(ex|vide)\s*C/i) {  
      $communetype = $1;    
      if ($version =~ /trident/i) {$communetype = 'ex';}
      if ($srank[3] =~ /(C[0-9]+[a-z]*)/i) {
	      $commune = $1;
	 	  $dayname[1] .= " $communetype $communesname{$commune} [$commune]";
      } 
      my $fname="$datafolder/$lang1/Commune/$commune" . "p.txt";     
      if ($dayname[0] =~ /Pasc/i && (-e $fname)) 
      {$commune .= 'p';}
 		  if ($commune) {$commune = "Commune/$commune.txt";}
    
   } elsif ($srank[3] =~ /(ex|vide)\s*Sancti\/(.*)\s*$/i) {
    $communetype = $1;
    $commune="Sancti/$2.txt";  
    if ($version =~ /trident/i) {$communetype = 'ex';}
   }  
                   
   if (transfered($tname)) { #&& !$vflag) 
      $dayname[2] = "Transfer $trank[0]";
      $commemoratio = '';
      
    } elsif ($version =~ /1960/ && $winner{Rule} =~ /Festum Domini/i && $trank =~ /Dominica/i) {
      $trank = ''; @trank = undef;

    } elsif ($trank[2] && $trank[2] > 1 && $trank[2] >= $crank[2]) {
      $dayname[2] = "Commemoratio: $trank[0]";  
      $commemoratio = $tname;
      $commemorated = $tcommemorated;
      $comrank = $trank[2];
      $cvespera = $tvesp;
      
    } elsif ($crank[2]) {  
      $dayname[2] = "Commemoratio: $crank[0]";
      $commemoratio1 = ($trank[2] > 1) ? $tname : '';
      $commemoratio = $cname;
      $commemorated = $ccommemorated;
      $comrank = $crank[2];
      $cvespera = 4 - $svesp;         
    
    } else {$dayname[2] = ''; $commemoratio = '';}

    %w = %{officestring("$datafolder/$lang1/$winner")};      
    if ($hora =~ /matutinum/i || !$dayname[2]) { 
      my %scrip = %{officestring("$datafolder/$lang1/$tname")};  
      if (!exists($w{"Lectio1"}) && exists($scrip{Lectio1}) && $scrip{Lectio1} !~ /evangelii/i && 
        ($w{Rank} !~ /\;\;ex / || ($version =~ /trident/i && $w{Rank} !~ /\;\;(vide|ex) /i) ) ) 
      {$dayname[2] = "Scriptura: $trank[0]";}
      else {$dayname[2] = "Tempora: $trank[0]" }
     $scriptura = $tname;

    }
   
  } else {    #winner is de tempore
    
	if (($dayname[0] !~ /(Adv|Quad)/i || $dayname[0] =~ /Quadp/i) &&
       ($dayofweek == 6 || ($hora =~ /Vespera|Completorium/i && $dayofweek ==5) && $version !~ /1960/)
	   && $trank[2] < 2) {   
      $tempora{Rank} = $trank = 'Sanctae Mariae Sabbato;;Feria;;2;;vide C10';
      $scriptura = $tname;
	  $tname = "Tempora/C10.txt";
      @trank = split(";;", $trank);    
    } 
           
    $rank = $trank[2];  
	  $dayname[1] = "$trank[0]  $trank[1]"; 
    $winner = $tname;                            
    $vespera = $tvesp;               
                           
    if ($trank[3] =~ /(ex|vide)\s*(.*)\s*$/i) {
      $communetype = $1;  
      my $name = $2;
      if ($name =~ /^C[0-9]/i) {$name = "Commune/$name";}
      if ($name !~ /(Sancti|Commune|Tempora)/i) {$name = "Tempora/$name";}
      $commune = "$name.txt";  
      if ($version =~ /trident/i) {$communetype = 'ex';}    
    }  
    
   
    if ($vespera == 1 && $rank >= 6 && $comrank < 5) {$commemoratio = ''; $srank[2] = 0;}
              
    if (transfered($sday) && $crank !~ /$srank/) {  
        $dayname[2] = "Transfer $srank[0]";  
        $commemoratio = '';
    
    } elsif ($srank[2]) {   
      %w = %{officestring("$datafolder/$lang1/$winner")};   
	    my $climit1960 = climit1960($sname);  
	    if ($w{Rule} !~ /omit.*? commemoratio/i && $climit1960) {  
        my $laudesonly = ($climit1960 > 1) ? ' Laudes only' : '';
		    $dayname[2] = "Commemoratio$laudesonly: $srank[0]";    
        $commemoratio = $sname;
        $cvespera = $svesp;
        $ccommemorated = $srank[0];
        $comrank = $srank[2];
	  } else {
        $dayname[2] = '';
        $commemoratio = '';
      }
    } 
  }

  if ($version =~ /trident/i && $communetype =~ /ex/i && $rank < 2) {$communetype = 'vide';}

  $comrank=~ s/\s*//g;
  $seasonalflag = ($testmode =~ /Seasonal/i && $winner =~ /Sancti/ && $rank < 5) ? 0 : 1;
  if (($month == 12 && $day > 24) || ($month == 1 && $day < 14)) {$dayname[0] = "Nat$day";}   
}

#*** next day for vespera
# input month, day, year
# returns the name for saint folder
sub nextday {
  my $month = shift;
  my $day = shift;
  my $year = shift;
  
  my $time = timelocal(0,0,12,$day,$month-1,$year);
  
  my @d = localtime($time + 60 * 60 * 24);
  $month = $d[4]+1;
  $day = $d[3];
  $year = $d[5]+1900;     
  return get_sday($month, $day, $year);
}

#*** leapyear($year)
# returns 1 if leapyear, otherwise 0
sub leapyear {
  my $year = shift;   
  if (($year % 400) == 0) {return 1;}
  if (($year % 100) == 0) {return 0;}
  if (($year % 4) == 0) {return 1;}
  return 0;
}

#*** get_sday($month, $day, $year)
# get a name (mm-dd) for sancti folder
sub get_sday {
  my $month = shift;
  my $day = shift;
  my $year = shift;

  if (leapyear($year) && $month == 2 && $day == 24) {$day = 29;} 
  if (leapyear($year) && $month == 2 && $day > 24) {$day -= 1;}
   
  $kalendarkey = sprintf("%02i-%02i", $month, $day);   
  return $kalendarkey;
}

#*** emberday 
# return 1 if emberday, 0 otherwise
# used $dayofweek, $dayname[0] season and week,
# for September the weekday office 
sub emberday {    
  if ($dayofweek < 3 || $dayofweek == 4) {return 0;}
  if ($dayname[0] =~ /Adv3/i) {return 1;}
  if ($dayname[0] =~ /Quad1/i) {return 1;}  
  if ($dayname[0] =~ /Pasc7/i) {return 1;}
  if ($month != 9) {return 0;}

  if ($winner{Rank} =~ /Quatuor/i || $commemoratio{Rank} =~ /Quatuor/i ||
    $scriptura{Rank} =~ /Quatuor/i) {return 1;}
  return 0;
}      

#*** gettoday($flag) 
#get the currend date in mm-dd-yyy format
# flag is set only for primary call for the standalone version
# for the web version javascrip function obtains the user's date
sub gettoday {
  my $flag = shift;
  if ($browsertime && !$flag) {return $browsertime;}

  
  my @date = localtime(time());
  my $month = @date[4]+1;
  my $day = @date[3];
  my $year = @date[5]+1900;
  return "$month-$day-$year";
}  

#*** precedence() 
# get date, rank, winner, preloads hashes
sub precedence {
                
  $winner = $commemoratio = $commune = $striptura = $commemoratio1 = '';
  %winner = %commemoratio = %commune = %scriptura = {};
  
  #get date
  $dat1 = shift;
  if (!$dat1) {$dat1 = ($Tk || $Hk) ? $date1 : strictparam('date');}
  $date1 = $dat1;   
  if ($votive =~ /hodie/ && !$Hk) {$date1 = gettoday();}  
  $vtv = ($votive =~ /(Dedication|C8)/i) ? 'C8' : ($votive =~ /(Defunctorum|C9)/i) ? 'C9' :
    ($votive =~ /(Parvum|C12)/i) ? 'C12' : '';
  
  if ($vtv !~ /(C8|C9|C12)/) {$votive = '';}    
  if ($date1) {
    $date1 =~ s/\//\-/g;
    @date1 = split('-', $date1);
    $month = $date1[0];
    $day = $date1[1];
    $year = $date1[2];      
    if ($month < 1 || $month > 12 || $day < 1 || $day > 31){ $date1 = '';}
  }
  if (!$date1) {($month, $day, $year) = split('-', gettoday());}
                                  
  if ($month) {$date1 = "$month-$day-$year";}  
  else {$date1 = '';} 

  @date1 = split('-', $date1);    
  $dayname = getweek(0); 
  @dayname=split('=', $dayname);
 
  getrank(); #fills @dayname, $winner, $commemoratio, $commune, $communetype, $rank);
  $duplex = 0;    
  if ($dayname[1] && $dayname[1] !~ /duplex/i) {$duplex = 1;}
  elsif ($dayname[1] =~ /semiduplex/i) {$duplex = 2;}
  else {$duplex = 3;}
 
  $rule = $communerule = '';    
    
  if ($winner) {   
    my $flag = ($winner =~ /tempora/ && $tvesp == 1) ? 1 : 0;
    %winner = %{officestring("$datafolder/$lang1/$winner", $flag)};      
    %winner2 = %{officestring("$datafolder/$lang2/$winner", $flag)};
    $rule = $winner{Rule};
  }
  			
  if ($winner =~ /Sancti/ && $rule =~ /Tempora none/i) {$commemoratio = $scriptura = '';}
  
  if ($commemoratio) {   
    %commemoratio = %{officestring("$datafolder/$lang1/$commemoratio")};
    %commemoratio2 = %{officestring("$datafolder/$lang2/$commemoratio")};
  }

  if ($scriptura) {     
    %scriptura = %{officestring("$datafolder/$lang1/$scriptura")};
    %scriptura2 = %{officestring("$datafolder/$lang2/$scriptura")};
  }  
  if ($commune) {     
    %commune = %{officestring("$datafolder/$lang1/$commune")}; 
    %commune2 = %{officestring("$datafolder/$lang2/$commune")};
    if ($commune =~ /C10/) {
      $rule .= "ex C10";
      $rule =~ s/Oratio Dominica//gi; 
      $winner{Rank} = 'Sanctae Mariae Sabbato;;Feria;;1;;ex C10';
    }
    if ($winner{Rank} =~ /\;\;ex\s/ || ($version =~ /Trident/i && $rank =~ /\;\;(ex|vide)/i && $duplex > 1)) 
      {$communerule = $commune{Rule};}

    if ($testmode =~ /Commune/i) {
      my $key;
      foreach $key (keys %winner) {
        if ($key =~ /Rank/i) {next;}
        if (exists($commune{$key})) {$winner{$key} = $commune{$key}}
        else {delete($winner{$key});}
      }
      foreach $key (keys %winner2) {
        if ($key =~ /Rank/i) {next;}
        if (exists($commune2{$key})) {$winner2{$key} = $commune2{$key}}
        else {delete($winner2{$key});}
      }
    }
  }
  
  if ($vtv) { 
    if ($vtv =~ /C12/i) {  
      if ($dayname[0] =~ /adv/i) {$vtv = 'C12A';}
      elsif ($dayname[0] =~ /Nat/i || ($month == 12 && $day > 24) || 
        $month == 1 || ($month == 2 && $day < 3)) {$vtv = 'C12N';}
    }  
	
	$winner = "Commune/$vtv.txt";
    $commemoratio = $commemoratio1 = $scriptura = $commune = $commemorated = '';
    %winner = updaterank(setupstring("$datafolder/$lang1/$winner"));
	%winner2 = updaterank(setupstring("$datafolder/$lang2/$winner"));
    %commemoratio = %scriptura = %commune = %commemoratio2 = %scriptura2 = %commune2 = {};
    $rule = $winner{Rule};
    if ($vtv =~ /C12/i) {
      @rank = split(';;', $winner{Rank});
      $commune = "Commune/C11.txt";
      $communetype = 'ex';
      %commune = updaterank(setupstring("$datafolder/$lang1/$commune"));
      %commune2 = updaterank(setupstring("$datafolder/$lang2/$commune"));
    }
    $dayname[1] = $winner{Name}; $dayname[2] = ''; 
  }	  

  if ($winner =~ /C10/) {
	  if ($month < 2 || ($month == 2 && $day < 3)) {    
	    $winner{'Ant 1'} = $winner{'Ant 11'};
		$winner{'Ant 2'} = $winner{'Ant 21'};
	    $winner2{'Ant 1'} = $winner2{'Ant 11'};
		$winner2{'Ant 2'} = $winner2{'Ant 21'};
		$winner{'Oratio'} = $winner{'Oratio 21'};
	  } elsif ($dayname[0] =~ /Pasc/i) {
	    $winner{'Ant 1'} = $winner{'Ant 13'};
		$winner{'Ant 2'} = $winner{'Ant 23'};
	    $winner2{'Ant 1'} = $winner2{'Ant 13'};
		$winner2{'Ant 2'} = $winner2{'Ant 23'};
	  }
  }


  $laudes = 1;	
  if ((($dayname[0] =~ /Adv|Quad/i || emberday()) && $winner =~ /tempora/i &&
     $winner{Rank} !~ /(Beatae|Sanctae) Mariae/i) ||
    ($winner{Rank} =~ /vigil/i && $version !~ /(1955|1960)/))  {$laudes = 2;}
  if ($version =~ /trident/i) {$laudes = '';}
}

#*** monthday($flag)
# returns an empty string or mmn-d format 
# e.g. 081-1 for monday after the firs Sunday of August
sub monthday {
  my $flag = shift;	 
  if ($month < 7 || $dayname[0] =~ /Adv/i) {return '';}

  my @ftime = splice(@ftime, @ftime);
  my ($fday, $fmonth);
  for ($m = 8; $m < 13; $m++) { 
    my $t = timelocal(0, 0, 12, 1, $m - 1, $year);  #time for the first day of month
    my @d = localtime($t);
    my $dofweek = $d[6];  
    if ($version =~ /1960/) {$fday = ($dofweek == 0) ? 1 : 8 - $dofweek; $fmonth = $m;}
    else {
      my @ldays = (31,31,30,31,30);
      if ($dofweek == 0) {$fday = 1; $fmonth = $m;}
      elsif ($dofweek < 4) {$fday = $ldays[$m - 8] - $dofweek + 1; $fmonth = $m - 1;}
      else {$fday = 8 - $dofweek; $fmonth = $m;}
    }
  
  $ftime[$m - 8] = timelocal(0, 0, 12, $fday, $fmonth - 1, $year);  
  }
 
  my ($d1, $m1, $y1) = ($day, $month, $year);
  if ($flag) {($d1, $m1, $y1) = nday($day, $month, $year);}

  my $ta = timelocal(0, 0, 18, $d1, $m1 - 1, $y1);
  if ($ta < $ftime[0]) {return '';}
  for ($m = 9; $m < 13; $m++) {
    if ($ta < $ftime[$m - 8]) {last;}
  }						 
                                     
  my $tdays = floor(($ta - $ftime[$m - 9]) / 86400);   
  my $weeks = floor($tdays / 7); 
  if ($m == 12 && $weeks > 0) {
    my $daysec = 60 * 60 * 24;
    my $t = timelocal(0,0,12,$date1[1],$date1[0]-1,$date1[2]);
    my $advent1 = getadvent($year);
    my $wdist = floor(($advent1 - $t - 3600) / (7 * $daysec));
    $weeks = 4 - $wdist;
  }
  my $monthday = sprintf('%02i%01i-%01i', $m - 1, $weeks + 1, $dayofweek);
  return $monthday;
}

#*** officestring($fname, $flag)
# same as setupstring (in dialogcommon.pl = reads the hash for $fname office)
# with the addition that for the monthly ferias/scriptures (aug-dec)
# it adds that office to the otherwise empty season related one
# if flag is 1 looks for the anticipated office for vespers
# returns the filled hash for the ofiice
sub officestring {
  my ($fname, $flag) = @_;  
  
  my %s;
  if ($fname !~ /tempora\/(Pent|Epi)/i) {
    %s = updaterank(setupstring($fname));
	return \%s;
  }
  if ($fname =~ /tempora\/Pent([0-9]+)/i && $1 < 5) {
    %s = updaterank(setupstring($fname));
	return \%s;
  }
  $monthday = monthday($flag); 
  if (!$monthday) {
    %s = updaterank(setupstring($fname));
	return \%s;
  }
  %s = %{setupstring($fname)};
  if (!%s) {return '';}
  my @rank = split(';;', $s{Rank});
  my $m = 0;
  my $w = 0;
  if ($monthday =~ /([0-9][0-9])([0-9])\-[0-9]/) {$m = $1; $w = $2;}
  my @months = ('Augusti', 'Septembris', 'Octobris', 'Novembris', 'Decembris');
  my @weeks = ('I.', 'II.', 'III.', 'IV.', 'V.');
  if ($m) {$m = $months[$m - 8];}
  if ($w) {$w = $weeks[$w - 1];}
  $rank[0] .= " $w $m";
  $str = "$rank[0];;$rank[1];;$rank[2]";
  if ($rank[3]) {$str .= ";;$rank[3]";}
  $s{Rank} = $str;
  my $lang = 'Latin';
  if ($fname =~ /\/(.*?)\/Tempora/i) {$lang = $1;}
  my %m = %{setupstring("$datafolder/$lang/Tempora/$monthday.txt")};
  foreach $key (keys %m) {$s{$key} = $m{$key}; }
  %s = updaterank(\%s);
  return \%s;
}

#*** nday($day, $month, $year)
# returns ($day, $month, $year) values for the following day
sub nday {
  my ($day, $month, $year) = @_;
  my $time = timelocal(0,0,12,$day,$month-1,$year);
  my @d = localtime($time + 60 * 60 * 24);
  
  $month = $d[4]+1;
  $day = $d[3];         
  $year = $d[5]+1900;     
  return ($day, $month, $year);
}

#*** transfered($tname | $sday)
# returns true if the day for season or saint is transfered
# otherwise false
sub transfered { 
  my $str = shift;
  if (($version =~ /(1955|1960)/ && $transfer1960 =~ /$str/i) ||
    ($version =~ /Trid/i && $transferTrid =~ /$str/i)) {return 0;}
  my $key;		
  foreach $key (keys %transfer) {if ($transfer{$key} =~ /$str/i && $transfer{$key} !~ /$str\s*a/i) 
    {return 1;}}
  if ($version =~ /(1955|1960)/) {
    foreach $key (keys %transfer1960) {if ($transfer1960{$key} =~ /$str/i) {return 1;}}
  }
  elsif ($version =~ /Trid/i) {
    foreach $key (keys %transferTrid) {if ($transferTrid{$key} =~ /$str/i) {return 1;}}
  }
  return 0;
}

#*** climit1960($commemoratio)
# return 1 if commemoratio is allowed for 1960 rules
sub climit1960 {
  my $c = shift;            
  if (!$c) {return 0;}
  if ($version !~ /1960/ || $c !~ /sancti/i) {return 1;}
  my %w = updaterank(setupstring("$datafolder/Latin/$winner"));
  if ($winner !~ /tempora/i) {return 1;}
  my %c = updaterank(setupstring("$datafolder/Latin/$c"));
  my @r = split(';;', $c{Rank});   
  if ($w{Rank} =~ /Dominica/i) {
    if ($r[2] >= 6) {return 1;}
    if ($r[2] >= 5 && $rank < 6) {return 1;}
  } elsif ($r[2] >= 6) {return 1;}
  elsif ($r[2] > 1) {return 2;}
  return 0;
}

#*** setheadline();
# returns the winner name and rank, different for 1960
sub setheadline {
  my $name = shift;
  my $rank = shift;     
                     
  if ((!$name || !$rank) && exists($winner{Rank})) {  
    my @rank = split(';;', $winner{Rank});
 	  $name = $rank[0];
	  $rank = $rank[2];
  }
  
  if ($name && $rank) {
	my $rankname = '';

    if ($name !~ /(Feria|Sabbato)/i) {
	  my @tradtable = ('none', 'Simplex', 'Semiduplex', 'Duplex', 'Duplex majus', 
        'Duplex II. classis', 'Duplex I. classis', 'Duplex I. clasis');
      my @newtable = ('none', 'Commemoratio', 'III. classis', 'III. classis', 'III. classis',
        'II. classis', 'I. classis', 'I. classis');
    
 	  $rankname = ($version !~ /1960/) ? $tradtable[$rank] : $newtable[$rank];
	} else {
	   if ($version !~ /1960/) {
		 $rankname = ($rank < 2) ? '' : ($rank < 3) ? 'Feria major' : 'Feria privilegiata';
	   } else {
	     my @ranktable = ('', 'IV. classis', 'III. classis', 'II. classis', 'II. classis',
		   'II. classis', 'I. classis', 'I. classis'); 
		 $rankname = $ranktable[$rank];
	   }
	}
    return "$name ~ $rankname";
  } else {return $dayname[1];}
}

#*** updaterank \%office
#updates $office{Rank} for 1960 Trid versions if any
sub updaterank {  
  my $w = shift;  
  my %w = %$w;   
  if (!exists($w{Rank})) {return %w;}  
  if ($version =~ /(1955|1960)/ && exists($w{Rank1960})) {$w{Rank}=$w{Rank1960}; }
  if ($version =~ /Trident/i && exists($w{RankTrident})) {$w{Rank}=$w{RankTrident};}
  return %w;
}
