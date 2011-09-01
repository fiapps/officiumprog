#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 09-25-08
# Divine Office Ordo

package horas;
#1;

#use warnings;
#use strict "refs";
$a = 4;

sub ordo { 
  $hora = '';
  my $saveonly = $only;
  $only = 0;

  $kyear = shift;
  $kmonth = shift;
  @origyear = split('-', gettoday()); 
  if (!$kmonth) {$kmonth = $origyear[0]; $kyear = $origyear[2];}
  if (!$version) {$version = 'Divino Afflatu';} 

  $smallgray = $smallblack;
  $boldblue = addattribute($bluefont, 'bold', $blue); 
  $boldblack = addattribute($blackfont, 'bold', $black);
  $boldred = addattribute($blackfont, 'bold', $red);
  $italicblue = addattribute($linkfont, 'italic', $blue);
  $italicblack = addattribute($blackfont, 'italic', $black);
  $italicred = addattribute($blackfont, 'italic', $red);

  ordorut($kmonth, $kyear);
  $mw->configure(-title=>$title);


  $mw->bind("<Key-Down>"=>sub{$mwf->yview(scroll, "$scrollamount", 'units')}); 
  $mw->bind("<Key-Up>"=>sub{$mwf->yview(scroll, "-$scrollamount", 'units')}); 
  $mw->bind("<Key-Next>"=>sub{$mwf->yview('scroll', "0.5", 'pages')}); 
  $mw->bind("<Key-Prior>"=>sub{$mwf->yview('scroll', "-0.5", 'pages')}); 
  $mw->bind('<MouseWheel>' => \&mouse_scroll);
  $only = $saveonly;
}

sub ordorut {
  my $kmonth = shift;
  my $kyear = shift; 

@monthnames = ('Januarius', 'Februarius', 'Martius', 'Aprilis', 'Majus', 'Junius',
  'Julius', 'Augustus', 'September', 'October', 'November', 'December');
@monthlength = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
@daynames = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fry', 'Sat');

$title = "Ordo: $version $monthnames[$kmonth-1] $kyear";
                                  
if ($mwf) {$mwf->destroy();}
$mw->idletasks();

$mwf = $mw->Scrolled('Pane', -scrollbars=>'osoe',
 -width=>$fullwidth, -height=>$fullheight, -background=>$framecolor)
 ->pack(-side=>'top', -padx=>$padx, -pady=>$pady);

#*** topframe
$topframe = $mwf->Frame(-background=>$framecolor)->pack(-side=>'top', -pady=>$pady);
$top1 = $topframe->Frame(-background=>$framecolor)->pack(-side=>'top');
my $i;
for ($i = $kyear - 9; $i <= $kyear; $i++) {setky($top1, $i);}
$top1->Button(-text=>'hodie', -background=>$framecolor, -borderwidth=>0, -foreground=>$blue,
  -command=>sub{$date1 = gettoday(); mainpage();})
  ->pack(-side=>'left', -padx=>$padx);
for ($i = $kyear + 1; $i < $kyear + 10; $i++) {setky($top1, $i);}

$top2 = $topframe->Frame(-background=>$framecolor)->pack(-side=>'top');
my $lb = $top2->Label(-text=>$title, -background=>$framecolor)->pack(-side=>'left', -padx=>$padx);
configure($lb, $framecolor, $titlefont, $titlecolor);

$top3 = $topframe->Frame(-background=>$framecolor)->pack(-side=>'top');
for ($i = 1; $i < 13; $i++) {setkm($top3, $i);}


$bottomframe = $mwf->Frame(-background=>$framecolor)->pack(-side=>'top', -pady=>$pady);

my $rdng = ($ordostatus =~ /Readings/i) ? 'Ordo' : 'Readings';
$printbutton1 = $bottomframe->Button(-text=>$rdng, -background=>$framecolor, -borderwidth=>0, -foreground=>$blue,
  -command=>sub{$ordostatus = $rdng; ordorut($kmonth, $kyear);})
  ->pack(-side=>'left', -padx=>$padx);

@versions = ('Trident 1570', 'Trident 1910', 'Divino Afflatu', 'Reduced 1955', 'Rubrics 1960', '1960 Newcalendar');
unshift(@versions, 'pre Trident Monastic');
$bottomframe->Optionmenu(-options=>\@versions,-textvariable=>\$version, #-background=>$framecolor,
   -border=>1, -command=>sub{ordorut($kmonth, $kyear);})
   ->pack(-side=>'left', -padx=>$padx);

$printbutton2 = $bottomframe->Button(-text=>'Exit', -background=>$framecolor, -borderwidth=>0, -foreground=>$blue,
  -command=>sub{exit()})
  ->pack(-side=>'left', -padx=>$padx);


$middleframe = $mwf->Frame(-background=>'#cccccc', -borderwidth=>1, -relief=>'solid')
  ->pack(-side=>'top', -pady=>$pady);

my $columns = 6;
my $fname;
if (!$ordostatus) {mainpage(); return;}
elsif ($ordostatus =~ /Readings/i) {$fname = Readings(); $columns = 3;}
else {$fname = ordohtml($version, $kyear, $kmonth);}

 if (!open(INP, "$datafolder/Ordo/$fname.html")) {print "$datafolder/Ordo/$fname.html cannot open!\n"; return;}
 my @a = <INP>;
 close INP;
 my $str = '';
 foreach $line (@a) {$str .= $line;};
 $str =~ s/[\n;]//g;
 $str =~ s/(\<TR.*?\>)/;;;$1/g;
 @a = split(';;;', $str);
 my $i = 0;
 my $fground = 'black';
 foreach $line (@a) { 
   $bold = ($line =~ /bold/i) ? 'bold' : '';
   $color = ($line =~ /(red|maroon|blue|gray)/i) ? $1 : $black;
     if ($line =~ /\<TH/) {$fground = 'maroon';}
     if ($line =~ /\<T[DH].*?\>/i) {
     $line =~ s/\<TR.*?\>//g;
     $line =~ s/\<T[DH].*?\>/;;/g;
	 $line =~ s/\n//g;
	 $line =~ s/\<BR\>/\n/gi;
	 $line =~ s/\<.*?\>//g;   
	 my @l = split(';;', $line);
	 my $j = 0;
	 
	 foreach $l (@l) {
	   if ($j == 0) {
	     if ($l =~ /[0-9]+ Sun/) {$fground = 'red';}
	   	 elsif ($l =~ /[0-9]+ [a-z]+/i) {$fground = 'black';}
       }
	   if (!$l || $l =~ /^\s*$/) {if ($j == 0) {next;} else { $l = '--'}}
	   my $bground = ((($i-1) % 4) > 1) ? $framecolor : '#eeeeee';
	   $font = "{Arial} 10";
	   if ($bold) {$font .= " bold";}
       #$font .= " $color";
	   $middleframe->Label(-text=>$l, -foreground=>$color, -background=>$bground, 
	     -font=>$font, -justify=>'left', -anchor=>'w')
	     ->grid(-row=>$i, -column=>$j, -sticky=>'nsew', -padx=>1, -pady=>0);
       $j++;
     }
	 $i++;
   }
 }
}
sub setky {
  my $widg = shift;
  my $year = shift;

  my $y = sprintf("%02i", $year);
  $widg->Button(-text=>$y, -background=>$framecolor, -borderwidth=>0, -foreground=>$titlecolor,
    -command=>sub{$kyear = $year; ordorut($kmonth, $kyear);})
    ->pack(-side=>'left', -padx=>$padx);
}

sub setkm {
  my $widg = shift;
  my $month = shift;   

  my $m = substr($monthnames[$month-1], 0, 3);
  $widg->Button(-text=>$m, -background=>$framecolor, -borderwidth=>0, -foreground=>$titlecolor,
    -command=>sub{$kmonth = $month; ordorut($kmonth, $kyear);})
    ->pack(-side=>'left', -padx=>$padx);
}

sub addattribute {
  my ($font, $attrib, $color) = @_;
  my ($fonttype, $fontsize) = ($font =~ /(\{.*?\})\s+([0-9]+)/) ? ($1, $2) : ('{Times}', 12);
  return "$fonttype $fontsize $attrib $color";
}


sub Readings {
  my @months = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  my @days = ('Sun', 'Mon', 'Tue', 'Wen', 'Thu', 'Fri','Sat');
  my @mnames = ('January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December');

  my $savehora = $hora;
  $hora = 'Laudes';

  if (!(-e "$datafolder/Ordo")) {mkdir "$datafolder/Ordo" or die "Ordo folder cannot be created";}
  if (!open(OUT, ">$datafolder/Ordo/Readings.html")) {print "$datafolder/Ordo/Readings.html cannot open!\n"; return;}

  print OUT "<HTML><HEAD><TITLE>Scriptural readings></TITLE></HEAD><BODY BGCOLOR=\"#ffffdd\">\n";
  print OUT "<P ALIGN=Center><B><I>Readings $mnames[$kmonth-1] $kyear</I></B></P>\n";
  print OUT "<TABLE WIDTH=98% BORDER=0 CELLPADDING=0 CELLSPACING=0 ALIGN=CENTER BGCOLOR=\"#ffffdd\">\n";
  print OUT "<TR><TH>Day</TH><TH>Passage</TH><TH><OFFICE</TH></TR>\n";
  
  for (my $kday = 1; $kday <= $months[$kmonth-1]; $kday++) {
    my $date1 = sprintf("%02i-%02i-%04i", $kmonth, $kday, $kyear);
    $d1 = sprintf("%02i",  $kday);
    $winner = $commemoratio = $scriptura = '';
    %winner = %commemoratio = %scriptura = {};
    $initia = 0;

    my $savekyear = $kyear;
	my $savekmonth= $kmonth;
	my $savekday = $kday;
    $dayname[0] = '';
	precedence($date1); #for the daily item      
    $kyear = $savekyear;
	$kmonth = $savekmonth;
	$kday = $savekday;
	
	my $line = "$d1 $days[$dayofweek]";
	if ($dayofweek == 0) {$line = "<B>$line</B>";}
	$line = "<TR><TD>$line</TD><TD>";  
	foreach $i (1,2,3) {
	  my $w = lectio($i, 'Latin');
	  if ($w =~ /!([0-9]*\s*[a-z]+ [0-9]+:[0-9]+)/i) {$line .= "$1, "}
    }
  print OUT "$line</TD><TD><I>$dayname[1]</I><\TD><\TR>\n";

  }	
  print OUT "<\TABLE></BODY></HTML>\n";
  close OUT;	
  return 'Readings';
 }


sub ordohtml { 
  my $version = shift;
  my $kpyear = shift;
  my $kpmonth = shift;
  my $kpday;
  $savehora = $hora;

  my @monthlength = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  my @mnames = ('January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December');
  my @days = ('Sun', 'Mon', 'Tue', 'Wen', 'Thu', 'Fri','Sat');

  my $kalendarname = ($version =~ /Monastic/i) ? '500' 
    : ($version =~ /1570/) ? 1570 : ($version =~ /Trident/i) ? 1911 
    : ($version =~ /newcal/i) ? '2009' : ($version =~ /1960/) ? 1960 : 'DA';     
  my $filename = "K$kalendarname/$kpyear-$kpmonth";
  if (!(-e "$datafolder/Ordo")) {mkdir "$datafolder/Ordo" or die "Ordo folder cannot be created";}
  if (!(-e "$datafolder/Ordo/K$kalendarname")) {mkdir "$datafolder/Ordo/K$kalendarname" 
    or die "$datafolder/Ordo/K$kalendarname cannot be created";}
   

  if (!open(OUT, ">$datafolder/Ordo/$filename.html")) {print "$datafolder/Ordo/$filename.html cannot open!\n"; return;}

  $knames = '';
  if (open(INP, "$datafolder/knames.txt")) {
    while ($l = <INP>) {$knames .= $l;}
	close INP; 
	$knames =~ s/\n/;/g;
	%knames = split(';', $knames);
  }
  
  %commonnames = split( ';;', 
    "C1;;Apostle;;C1a;;Evangelist;;C1v;;Vigil of Apostle;;C2;;one Martyr;;" .
    "C3;;many Martyrs;;C4;;Confessor Bishop;;" .
    "C4a;;Doctor, Bishop;;C5;;Confessor not Bishop;;C5a;;Doctor, not Bishop;;" .
    "C6;;one Virgin;;C6a;;many Virgins;;C6b;;Virgin, Martyr;;C7;;Martyr Holy Woman;;C7a;;Holy Woman;;" .
    "C8;;Dedication of a Church;;C9;;Dead;;C10;;B.M.V. on Saturday;;C11;;Blessed Virgin Mary");

  print OUT "<HTML><HEAD><TITLE>Ordo</TITLE></HEAD><BODY BGCOLOR=\"#ffffff\">\n";
  print OUT "<P ALIGN=CENTER><B><I>$version Ordo $kpyear $mnames[$kpmonth-1]</I></B></P>\n";
  print OUT "<TABLE WIDTH=98% BORDER=1 CELLPADDING=2 CELLSPACING=0 ALIGN=CENTER BGCOLOR=\"#dddddd\">\n";

  print OUT "<TR><TH>Day</TH><TH>R</TH><TH>Offices</TH><TH>Rank</TH><TH>Common</TH><TH>Specials</TH><TH>Commemoratio</TH></TR>\n";
	for ($kpday = 1; $kpday <= $monthlength[$kpmonth-1]; $kpday++) {
	for $hora ('Laudes', 'Vespera') { 
      my $date1 = sprintf("%02i-%02i-%04i", $kpmonth, $kpday, $kpyear);
      my $d1 = sprintf("%02i",  $kpday);
	  $winner = $commemoratio = $commemoratio1 = $commemorated = $scriptura = '';
      %winner = %commemoratio = %commemoratio1 = %commemorated = %scriptura = {};
	  $initaia = $laudesonly = '';
      
      my $savekyear = $kpyear;
	  my $savekmonth= $kpmonth;
  	  my $savekday = $kpday;
      precedence($date1); #for the daily item      
      $kpyear = $savekyear;
	  $kpmonth = $savekmonth;
	  $kpday = $savekday;


	  if ($commemorated) {%commemorated = %{officestring("$datafolder/$lang1/$commemorated")};}

	  my $col1 = "$d1 $days[$dayofweek]";
      if ($hora =~ /Vespera/i) {$col1 = ($vespera == 1) ? "-- V1" : "-- V2";}	  
      my @rank = split(';;', chompd($winner{Rank}));
	  my $col2 = "$rank[2]";
	  my $r3 = $rank[3];
	  my $col3 = "$rank[0]";
	  if ($version =~ /1960/) { 
	    $col3 = getkname($winner);
		if (($dayofweek == 0 || $rank[0] =~ /(Feria|Dominica)/i) && 
		    $rank[0] =~ / (III|II|IV|I|V)\.\s(August|Septembr|Octobr|Novembr|Decembr)/i) 
	      {$col3 .= (' ' . $knames{$1} . ' ' . $knames{$2});} 
        if ($kpmonth == 9 && $rank[0] =~ /Quattuor/i) {$col3 = $knames{"Ember$dayofweek"};}
	  }


	  if ($commemoratio1) {
		if ($version =~ /1960/) {$r[2] = floor($r[2]);}
	    my @r = split(';;', chompd($commemoratio1{Rank}));
		if ($r[2] >= 2 || $vespera != 1) {
	      if ($version =~ /1960/) {$col3 .= '<BR>' . getkname($commemoratio1);}
		  else {$col3 .= "<BR>$r[0]";}
		  $col2 .= "<BR>$r[2]";
		}
	  }
	  if ($commemoratio) {
	  	my @r = split(';;', chompd($commemoratio{Rank}));
		if ($version =~ /1960/) {$r[2] = floor($r[2]);}
		if ($r[2] >= 2 || $vespera != 1) {
	      if ($version =~ /1960/) {$col3 .= '<BR>' . getkname($commemoratio);}
		  else {$col3 .= "<BR>$r[0]";}
		  $col2 .= "<BR>$r[2]";
		}
	  }
     if ($commemorated) {
 	    my @r = split(';;', chompd($commemorated{Rank}));
		if ($version =~ /1960/) {$r[2] = floor($r[2]);}
		if ($r[2] >= 2 || $vespera != 1) {
	      if ($version =~ /1960/) {$col3 .= '<BR>' . getkname($commemorated);}
		  else {$col3 .= "<BR>$r[0]";}
		  $col2 .= "<BR>$r[2]";
		}
	  }
      
	  if ($hora =~ /Laudes/i) {
	    my $sti = initiarule($kpmonth, $kpday, $kpyear);
	    $sti =~ s/\~[a-z]//ig;
		if (!$sti && $version !~ /1960/ && $rule =~ /StJamesRule=([a-z,]+)\s/i) 
	      {$sti = StJamesRule(\%winner, 'Latin', 1, $1);} 
		if ($sti) {$col3 .= "<BR>Scriptura transfer : $sti";}
      }

      my @cf = split('~', setheadline($rank[0], $rank[2])); 
	  my $col4 = $cf[1];
	  $col4 =~ s/classis/class/;
	  my $col41 = '';
	  if ($r3) {
	    $col41 = chompd($r3);
	    $col41 =~ s/(ex|vide|sancti|tempora)//gi;
		$col41 =~ s/[\/\s]//g;
		if (exists($commonnames{$col41})) {
		  my $ptime = ($col41 =~ /C[23]/i && $dayname[0] =~ /Pasc/i) ? 'Martyr Easter-time' : '';
		  $col41 = $commonnames{$col41};
		  if ($ptime) {$col41 = $ptime;;}
		}
	  } 

      my $col5 = '';
	  my ($dox, $dname) = doxology('', 'Latin');
	  if ($dox || $dname) {$col5 .= 'Doxology<BR>';}
	  if ($hora =~ /Laudes/i) {
	    if ($laudes == 2) {$col5 .= 'Laudes2<BR>';}
	    if (exists($winner{'Ant Matutinum'}) || exists($winner{'Ant Laudes'})) {$col5 .= 'Ant. Psalm.<BR>';}
        if (exists($winner{'Capitulum Laudes'}) || exists($winner{'Capitulum Tertia'})) {$col5 .= 'Capitulum<BR>';} 
  	    if (exists($winner{'Hymnus Matutinum'}) || exists($winner{'Hymnus Laudes'})) {$col5 .= 'Hymnus<BR>';}
        if (exists($winner{'Ant 2'})) {$col5 .= 'Ant. Bened.<BR>';}
	    if (preces('Feriales') == 0) {$col5 .= 'Preces F.<BR>';}
	    if (preces('Dominicales') == 0 && $version !~/(1955|1960)/) {$col5 .= 'Preces D.<BR>';}
        if (checksuffragium() && $version !~ /(1955|1960)/) {$col5 .= 'Suffr.<BR>';}
      }
      if ($hora =~ /Vespera/i) {
		if  (exists($winner{'Ant Vespera'}) || exists($winner{'Ant Vespera3'})) {$col5 .= 'Ant. Psalm.<BR>';}
	    if (exists($winner{'Capitulum Vespera'}) || exists($winner{'Capitulum Vespera 3'})) {$col5 .= 'Capitulum<BR>';} 
	    if (exists($winner{'Hymnus Vespera'}) || exists($winner{'Hymnus Vespera3'}) ) {$col5 .= 'Hymnus<BR>';}
	    if (exists($winner{'Ant 1'}) || exists($winner{'Ant 3'})) {$col5 .= 'Ant. Magn.<BR>';}
	    if (preces('Feriales') == 0) {$col5 .= 'Preces F.<BR>';}
	    if (preces('Dominicales') == 0 && $version !~/(1955|1960)/) {$col5 .= 'Preces D.<BR>';}
        if (checksuffragium() && $version !~ /(1955|1960)/) {$col5 .= 'Suffr.<BR>';}
	  }
	  $col5 =~ s/\<BR\>$//; 

      $octavam = '';
	  my %cc = oratio($lang1, $kpmonth, $kpday); 
      my $col6 = '';
      foreach $key (sort keys %cc) { 
        if ($key >= '0900') {  
		   my $cname = $cc{$key}; 
		   if ($cname =~ /!(.*?)\n/) {$cname = $1;} else {$cname = '';}
		   if ($cname) {
		     $cname =~ s/Commemoratio[n]*//i;
             $cname =~ s/(for|pro) //i;
			 $cname =~ s/^\s*//;
			 if (length($cname) > 5) {$col6 .= "$cname<BR>";}
           }
        }
      }
      $col6 =~ s/\<BR\>$//; 

	  my $style = '';
	  if ($hora =~ /Laudes/i && ($dayofweek == 0 || holyday($winner))) {$style .= "font-weight:bold;";}
	  if ($col41 =~ /(B\.M\.V\.|Blessed Virgin Mary)/) {$style .= "color:blue;"}
	  elsif ($col2 >= 6) {$style .= "color:red;"}
	  elsif ($col2 >= 5) {$style .= "color:maroon;"}
	  elsif ($col2 < 2) {$style .= "color:grey;"}
	  if ((($kpday-1) % 2) == 0) {$style .= "background-color:#ffffdd;";} 
	  if ($style) {$style = "style=\"$style\"";}
	  my $tr .= "<TR $style>"; 

      print OUT "$tr<TD>$col1</TD><TD>$col2</TD><TD>$col3</TD>";
	  if ($col4) {print OUT "<TD>$col4</TD>";}
	  else {print OUT "<TD ALIGN=CENTER>--</TD>";}
	  if ($col41) {print OUT "<TD>$col41</TD>";}
	  else {print OUT "<TD ALIGN=CENTER>--</TD>";}
	  if ($col5) {print OUT "<TD>$col5</TD>";}
	  else {print OUT "<TD ALIGN=CENTER>--</TD>";}
	  if ($col6) {print OUT "<TD>$col6</TD>";}
	  else {print OUT "<TD ALIGN=CENTER>--</TD>";}
	  
	  
	  print OUT "</TR>\n";
    }
	}
  
 print OUT "</TABLE></BODY></HTML>\n";
 close OUT;
 return $filename;
}


sub getkname {
  my $item = shift;
  my $key;
  if ($item =~ /Tempora/i && $item =~ /([a-z0-9]+\-[0-9])/i) {
    $key = $1;
	if ($dayofweek == 0 && $kpmonth > 7 && $key =~ /^Epi/) {$key = 'P' . $key;}
	if (exists($knames{$key})) {return $knames{$key};}
	if ($key =~ /Adv/i) {return $knames{Adv};}	
	if ($key =~ /Quad[1-4]/i) {return $knames{Quad};}
	if ($key =~ /Quad5/i) {return $knames{Quad5};}
	if ($key =~ /Pasc/i) {return $knames{Pasc};}
    return 'Feria';
  } 
  if ($item =~ /Sancti/i && $item =~ /([0-9][0-9]\-[0-9D][0-9U])/) {
    $key = $1;
	if (exists($knames{$key})) {
	  my $name = $knames{$key};
	  if ($name =~ /==/) {$name = $`;}
	  return $name;
	}
  }
  if ($item =~ /C10/i) {return $knames{C10};}
  %w = officestring("$datafolder/Latin/$item");
  my @r = split(';;', $w{Rank});
  return $r[0];
}

sub holyday {
  my $w = shift;
  if ($w =~ /(Pasc5-4|12-08|12-25)/) {return 1;}
  if ($w =~ /(01-01|08-15|11-01)/ && $dayofweek != 1 && $dayofweek != 6) {return 1;}
  return 0;
}