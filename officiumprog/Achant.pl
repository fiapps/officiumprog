#!/usr/bin/perl
# áéíóöõúüûÁÉÍÓÚæ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office

$a = 1;

#*** singit($text, $tfile, $tone, $linenum, $pitchflag)
# converts text to meta -> pho format and plays it using phoplayer.exe
sub singit {
  my $text = shift;    
  my $tfile = shift;   
  my $tone = shift; 
  my $psalmline = shift;
  my $lineind = shift;
        
  $chanttype = ($tfile =~ /^H\-/) ? 'Hymn' : ($tfile =~ /^p/i) ? 'Psalm' : 'Syllabic';
  
  our $doline = 8;
  our $clef = 'do=8';
  our $syllabletime = $basetime;
  if ($chanttype =~ /^Psalm/i) {$text = psalmflex($text);}
  $text = praepare($text);
  $text = compose($text, $chanttype, $tone, $psalmline, $lineind);  
  $text = playmetarut($text, $lineind & 1);  
  playphorut($text);
  return 1;
}

#*** psalmflex($verse)
# inserts additional * for flex 
# if first part longer than 50 
# and there is ,;: separator
sub psalmflex {
  my $verse = shift;      
  my @verse = split('\*', $verse);
  my $len = length($verse[0]);        
  if ($len < 50 || $verse[0] !~ /[,;:?]/) {return $verse;}
  my $half = floor($len/2);
  my $i = $half;                               
  while ($i > 10) {
    my $c = substr($verse[0], $i, 1);
    if ($c =~ /[,;:?]/) {last;}
    $i--;
  }
  $hdist1 = ($i > 10) ? $half - $i : 1000;
  my $i = $half + 1;
  while ($i < $len - 15) {
    my $c = substr($verse[0], $i, 1);
    if ($c =~ /[,;:?]/) {last;}
    $i++;
  }
  $hdist2 = ($i < $len - 15) ? $i - $half : 1000;
  my $k = 0;
  if ($hdist1 > 999 && $hdist2 > 999) {return $verse;}
  if ($hdist2 < $hdist1) {$k = $half + $hdist2;}
  elsif ($hdist1 < 1000) {$k = $half - $hdist1;}  
  if ($k > 0) {return substr($verse[0], 0, $k) . ' *' . substr($verse[0], $k + 1) . '*' . $verse[1];}
  else {return $verse;}
  
}

#*** praepare($p1)
# converts a repular ASCII line onto MBROLA accepted phonetic characters
sub praepare {
  my $p1 = shift;
  
  #punctuation to nothing
  $p1 =~ s/\.//mg;
  $p1 =~ s/\?//mg;
  $p1 =~ s/[,:;!"()\t]//mg;
  $p1 =~ s/\-/ /mg;	  
  
  if ($voicecolumn =~ /Magyar/i) {$p1 = praepare_magyar($p1);}
  else {$p1 = praepare_latin($p1);}
  return $p1;
}

sub praepare_magyar {
  my $p1 = shift;

  #no capital letters
  $p1 = lc($p1);
  
  #double consonants
  $p1 =~ s/ch/x/mg;
  $p1 =~ s/cs/tS/mg;
  $p1 =~ s/dzs/dZ/mg;
  $p1 =~ s/gy/dj/mg;
  $p1 =~ s/ly/j/mg;
  $p1 =~ s/ny/J/mg;
  $p1 =~ s/s/S/mg;
  $p1 =~ s/sz/s/mig;
  $p1 =~ s/ty/tj/mg;
  $p1 =~ s/c/ts/mg;

  #vowels  áéíóöõúüûÁÉÍÓÖÔÚÜÛ
  $p1 =~ s/e/e/mg;
  $p1 =~ s/a/o/mg;
  $p1 =~ s/[áÁÁ]/a:/mg;
  $p1 =~ s/[éÉ]/e:/mg;
  $p1 =~ s/[íÍ]/i/mg;
  $p1 =~ s/[óÓ]/o:/mg;
  $p1 =~ s/[öÖ]/q/mg;
  $p1 =~ s/[õÖôÔ]/q:/mg;
  $p1 =~ s/[úÚ]/U:/mg;
  $p1 =~ s/[üÜ]/y/mg;
  $p1 =~ s/[ûÛ]/y:/mg;

  $p1 = accent_magyar($p1);
  return $p1;
}

sub accent_magyar {
  my $p1 = shift;
  return $p1;
}


sub praepare_latin {
  my $p1 = shift;	 
						 
  #double consonants
  $p1 =~ s/bb/b:/ig;
  $p1 =~ s/cc([ei])/cks$1/ig;
  $p1 =~ s/cc/k:/ig;
  $p1 =~ s/dd/d:/ig;
  $p1 =~ s/ff/f/ig;
  $p1 =~ s/gg/g:/ig;
  $p1 =~ s/hh/h:/ig;
  $p1 =~ s/ll/l:/ig;
  $p1 =~ s/mm/m:/ig;
  $p1 =~ s/nn/n:/ig;
  $p1 =~ s/pp/p:/ig;
  $p1 =~ s/rr/r:/ig;
  $p1 =~ s/ss/s:/ig;
  $p1 =~ s/tt/t:/ig;
  $p1 =~ s/zz/z:/ig;
  $p1 =~ s/vu/uu/ig;
  $p1 =~ s/vú/uu/ig;
  $p1 =~ s/bs/ps/ig;

  #special consonants
  $p1 =~ s/ch/k/ig;
  $p1 =~ s/kh/k/ig;
  $p1 =~ s/ph/f/ig;
  $p1 =~ s/th/t/ig;
  $p1 =~ s/v/w/ig;
  $p1 =~ s/x/ks/ig;
  $p1 =~ s/qu/kw/ig;
  $p1 =~ s/gu([aeioiáéæíóú])/gw$1/ig;

  #accented add colon  éæí  áóú ÁÉÓÚ

  $p1 =~ s/ií/ii/ig;
  $p1 =~ s/é/e:/ig;
  $p1 =~ s/é/e:/ig;
  $p1 =~ s/æ/ae/ig;
  $p1 =~ s/Æ/ae/ig;
  $p1 =~ s/oe/e:/ig;
  $p1 =~ s/ae/e:/ig;
  $p1 =~ s/ë/e/ig;
  $p1 =~ s/au/a:/ig;
  $p1 =~ s/í/i:/ig;
  $p1 =~ s/á/a:/ig;
  $p1 =~ s/ó/o:/ig;
  $p1 =~ s/ú/u:/ig;
  $p1 =~ s/ý/i:/ig;
  $p1 =~ s/Á/a:/ig;
  $p1 =~ s/É/e:/ig;
  $p1 =~ s/Í/i:/ig;
  $p1 =~ s/Ó/o:/ig;
  $p1 =~ s/Ú/u:/ig;
  $p1 =~ s/([aeiou]:*)i([aeiou]:*)/$1j$2/ig;
  $p1 =~ s/(i:*)i/$1i:/ig;
  $p1 =~ s/iesu/jesu/ig;


  $p1 =~ s/ti(\:*)([aeiou])/tsi$1$2/ig;
  $p1 =~ s/c([ei])/ts$1/ig;
  $p1 =~ s/c/k/ig;	   


  #short words accent
  $p1 = accent_latin($p1);	 

  return $p1;
}

#*** accent_latin($p1)
# set the accent for the 2 syllable words
# accent is noted by a : after the vowel
sub accent_latin {
  my $p1 = shift;
  $p1 =~ s/  /~~/sg;		

  @p1 = split(' ', $p1);
  $p1 = '';
  my $w;
  foreach $w (@p1) {
    if ($w =~ /[aeiou]\:/ || $w !~ /[a-z]/i) {$p1 .= "$w "; next;}	  #already accented
	$w .= ' ';	
    my $l = length($w) - 1;
	my $flag = 0;
	$l1 = -1;
	while ($l >= 0) { 
	  my $s = substr($w, $l, 1);  
	  if ($s =~ /[aeiou]/i) {$flag++;}
	  if ($l > 0 && $s =~ /[aeiou]/ && substr($w, $l-1, 1) =~ /[aeiou]/i) {$flag--; $l1 = $l - 1;}  
	  if ($flag == 2 && $s =~ /[aeiou]/i) {	 
	    $w = substr($w, 0, $l) . "$s:" . substr($w, $l+1);	
	  }
      $l--;
	}
	if ($w !~ /\:/ && $l1 >= 0) {$w = substr($w, 0, $l1+1) . ':' . substr($w, $l1+1);} 
	
	$p1 .= $w;
  }
  $p1 =~ s/~~/\n/sg; 	 
  return $p1;
}

#*** compose($p1, $chanttype, $tone, $psalmline)
# converts $p1 line of a psalm to meta file, using @psalmtone (see chant.html)
# returns the meta string
sub compose {
  my $p1 = shift;
  my $chanttype = shift;		 
  my $tone = shift;
  my $psalmline = shift;
  my $lineind = shift;   
                                   
  if ($chanttype =~ /Recite/i) {return recite_line($p1, $tone);}
  elsif ($chanttype =~ /Psalm/i) {return psalm_line($p1, $tone, $psalmline);}
  elsif ($chanttype =~ /Hymn/i) {return hymnverse($p1, $tone, $lineind);}
  else {return syllabic($p1, $tone, $lineind);}
}

sub recite_line {
  my $p1 = shift;
  my $tone = shift;
  my @texttone = split("\n", $tone);
  return $p1;
}

sub hymnverse {
  my $p1 = shift;      
  my $tone = shift;
  $lineind = shift;   

  $tone =~ s/\s*$//;
  my @texttone = split("\n", $tone);
  if ($texttone[0] =~ /clef/i) {($doline, $dofreq) = getdo(shift(@texttone));}
  if ($p1 =~ /^\s*[ao]\:*men/i) {$texttone = ''; return syllabic_line($p1, $texttone[-1]);}
  else {
    if (@texttone > 1) {$lineind = $lineind % (@texttone - 1);}
    return syllabic_line($p1, $texttone[$lineind]);}
}

sub syllabic {
  my $p1 = shift;
  my $tone = shift;
  my $lineind = shift;
  my @texttone = split("\n", $tone);

  if ($texttone[0] =~ /clef/i) {($doline, $dofreq) = getdo(shift(@texttone));}
  return syllabic_line($p1, $texttone[$lineind]);
}

sub syllabic_rut {
  my $p = shift;	  
  my $tone = shift;
  
  my @p = split("\n", $p);
  my @tone = @$tone;

  my $metline = '';
  if ($tone[0] =~ /clef/i) {shift(@tone);}

  my $i;
  for ($i = 0; $i < @p; $i++) {	 
    $metline .= syllabic_line($p[$i], $tone[$i]);
  }
  return $metline;
}

sub syllabic_line {
  my $p = shift;
  my $tone = shift;	
  $p =~ s/\*//g;		
  
  if (!$p || $p =~ /^\s*$/) {return;}
  if (!$tone || $tone =~ /^\s*$/) {return;}

  my $slen = 0;
  while ($p =~ /[aeiouæ]/ig) {$slen++;}


  my @t = split(',', $tone);
  my $item;
  my $tlen = 0;
  foreach $item (@t) {
    if ($item =~ /b/i) {next;}
    $tlen++;
    if ($item =~ /\(([0-9]+)\)/) {$tlen += $1;} 
  }
            
  my $tone = '';
  foreach  $item (@t) {
    if ($item =~ /f/i && $slen < $tlen) {next;}
    if ($slen > $tlen && $item =~ /\./) {
      my $it = $item;
      if ($it =~ /~/) {$it = $`;}
      while ($slen > $tlen) {$tone .= "$it,", $tlen++;}
    }    

    if ($item =~ /\(([0-9]+)\)/) { 
	    my $note = $`;
	    my $n = $1;   
	    my $i;
	    for ($i = 0; $i < $n; $i++) {$tone .= "$note,";}
	  } else {$tone .= "$item,";}
  }
  my @tone = split(',',$tone);  

  my $line = $p;
  my $i = 0;
  my $j = 0;
  my $m = '';
  my $sy;

  while ($i < @tone) {
	  if ($tone[$i] =~ /b/i && $sy) {$m .= "$tone[$i],";$i++;next;}
	  ($sy, $j) = forwsyll($line, $j);
	  $m .= "$tone[$i],$sy,"; $i++;
  }

  return $m;
}

sub psalm_line {
  my $p1 = shift;
  $p1 =~ s/^\s*//;
  $p1 =~ s/\s*$//;      
  my @p1 = split('\*', $p1);   
  my $t = shift;   
  my @texttone = split("\n", $t);        
  my $psalmline = shift;   
  
  my @tone = split(',', $texttone[1]);
  my $line = $p1[0];
  my $i = 0;
  my $j = 0;
  my $m = "$texttone[0]";

  if (!@p1) {return $m;}

  if ($psalmline == 0) {
    while ($i < @tone - 1) {
	    my $sy;
	    if ($tone[$i] =~ /b/i) {$sy = '';}
	    else {
	    ($sy, $j) = forwsyll($line, $j);
	  }
	  $m .= "$tone[$i],$sy,"; $i++;}
  }
  $line = substr($line, $j);
  my $tone = (@p1 > 2) ? $texttone[2] : $texttone[3];
  
  #flex or middle
  $m .= processtone($line, $tone);
  
  #middle if flex
  if (@p1 > 2) {$m .= processtone($p1[1], $texttone[3]); }

  #cadence
  $m .= processtone($p1[-1], $texttone[4]);    
  return $m;
}

sub processtone {
  my $line = shift;
  my $tone = shift;

  my @tone = split(',',$tone);	
  
  my $i = @tone -1;
  my $j = length($line) - 1;   
   
  my $o = ''; 
  while ($i > 0 && $j > 0) {
	my $syll;
    if ($tone[$i]=~ /b/i) {$syll = '';}
    else {
	 ($syll, $j) = backsyll($line, $j);	
      while ($syll =~ /\:/ && $tone[$i] =~ /f/i && $i > 0) {$i--;}
	}
	$o = "$tone[$i],$syll,$o";
    $i--;
  }
  $o = "$tone[0]," . substr($line, 0, $j + 1) . ',' . $o;
  return "$o\n";
}

#*** forwsyll($line, $j)
# returns the $j-th syllable of $line moving forward
sub forwsyll {
  my $line = shift;
  my $j = shift;

  my $o = '';
  while ($j < length($line)) {
  my $let	= substr($line, $j, 1);
  if ($j < length($line) - 1 && substr($line, $j+1, 1) eq ':') {$let .= ':'; $j++;}
	$j++;
	$o .= $let;
	if (!vowel($let)) {next;} 
	$let = substr($line, $j, 1);
  if (vowel($let)) {last;}
  if ($j < length($line) - 1 && substr($line, $j+1, 1) eq ':') {$let .= ':'; $j++;}

  while ($j < length($line)) {
    $o .= $let;
    $j++;
    $let = substr($line, $j, 1);
    if (vowel($let)) {last;}
    next; 
	}
	last;
 }	  
 return ($o, $j);
}

sub vowel {
  my $let = shift;
  if ($let =~ /[aeiouæ]/i || ($voicecolumn =~ /magyar/i && $let =~ /[qy]/i)) {return 1};
  return 0;
}

#*** backsyll($line, $j)
# returns the $j-th syllable of $line moving backward
sub backsyll {
  my $line = shift;
  my $j = shift;

  my $o = '';
  while ($j >= 0) {
    my $let	= substr($line, $j, 1);
	$j--;
	if ($let eq ':') {
	  $let = substr($line, $j, 1) . $let;
	  $j--;
	}
	$o = $let . $o;
	if (!vowel($let)) {next;}
	if ($j >= 0) {
	  $let = substr($line, $j, 1);
	  if (!vowel($let) && $let !~ /[ \:]/) {$o = $let . $o; $j--}
	}
	last;
  }
  return ($o, $j);
}

#*** playmetarut($metastring, $pitchflag)
# converts the input metastring into a phosring and returns it
sub playmetarut {
  my $metastring = shift; 
  my $pitchflag = shift;     
  
  $metastring =~ s/\n//sg; 
  ($doline, $dofreq) = getdo($metastring);
  $prevfreq = 0;
  $nextfreq = 0;	 
  
  @metastring = split(',', $metastring);
  $phostring = ""; 
  
  my $prevlet = '';
  my $ii;
  for ($ii = 0; $ii < @metastring; $ii++) { 
    my $item = $metastring[$ii];		

    #clef: do|fa [=line]  getdo handles it
    if ($item =~ /^clef/i) {next;}
             
	#scale unit
    if ($item =~ /^\s*([0-9]+)/) {  
      my $n = $1;
 
      #break: <n>b
      if ($item =~ /b/i) { 
   	    $btime = $syllabletime / 2 * $n;
	    $phostring .= "_ $btime 50 $dofreq \n"; 
	    next;
	  }

	  #<n>-ptafvq[.[.]]
      #n = linenumber
	  #- = b (ind - 1 in chromatic)
	  #p=punct t=tenor, a=accented, f=filler, v=virga, q=diamond
	  #~ connecting another note for the same wovel
	  #. or .. for single or double elongating
      our $neuma = ($item =~ /\~/) ? $item : '';
	  
	  $mult = 1;
	  $be = ($item =~ /\-/) ? 1 : 0;
	  $actfreq = sprintf("%6.2f", getfreq($n, $be, $pitchflag)); 
	  $nextfreq = $actfreq;
      while ($ii < @metastring - 2) {
	    my $nextitem = $metastring[$ii + 2];	  
		my $nn = 0;
		if ($nextitem =~ /^\s*([0-9]+)/) {$nn = $1;}
		if (!$nn || $nextitem =~ /b/i || $item =~ /t/i) {last;}
	    my $nbe = ($nextitem =~ /\-/) ? 1 : 0;
	    $nextfreq = sprintf("%6.2f", getfreq($nn, $nbe, $pitchflag)); 
		last;
	  }
	  
    $acttime = $syllabletime;
    if ($item =~ /\.\./) {$mult = 2;}
    elsif ($item =~ /\./)  {$mult = 1.5;}
    elsif ($item =~ /a/i) {$mult = 1.25;}
    next;
    }

    if ($item =~ /([^a-z \:\n\t])/i) {$item = "$`$'";}
    #  my $l = length($item);
    #  my $i;
    #  my $t='';
    #  for ($i = 0; $i < $l; $i++) { $t .= ord(substr($item, $i, 1)); $t .= ',';}
    #  errorTk("Wrong character $1 in $item=$t;");  
    #  next;
    #}
	
  my @s1 = splice(@s1, @s1);
  my $j = 0;
  $vowelmult = $voweltime / 10;
  while ($j <	length($item)) {
    ($s1, $j) = forwsyll($item, $j);
    push(@s1, $s1); 
  } 
  
  foreach $s (@s1) {
    my @s = split('|', $s);
	  my $i = 0;
    
	  my $lettime = floor($acttime / (@s + $vowelmult - 1));  
    
    while ($i < @s) {
      $let = lc($s[$i]); 
      $i++;
			  
    if ($voicecolumn =~ /Latin/i) {
      if (($i >= @s || $s[$i] ne ':') && $let =~ /([eiou])/) {$let = uc($1);} 
  	  if ($i < @s && $s[$i] eq ':') {$let .=  ':'; $i++;}
					 
      if ($prevlet =~ /\:/ && $let !~ /[ei]/i)	{$let =~ s/\://;} 	   
	    if ($prevlet =~ /[nmrkdl]/i && $let =~ /u/i) {$let = 'u:'; }	 
	    if ($prevlet =~ /[nmrkdl]/i && $let =~ /o/i) {$let = 'o:'; }	 
	    if ($prevlet =~ /[nmrkdl]/i && $let =~ /e/i) {$let = 'E'; }	 
  		$let =~ s/a\:/a/ig;
	  
    } elsif ($voicecolumn =~ /Magyar/i) {  
      if (($i >= @s || $s[$i] ne ':') && $let =~ /([aeo])/) {$let = uc($1);} 
  	  if ($i < @s && $s[$i] eq ':') {$let .=  ':'; $i++;}
      if ($prevlet =~ /[msgd]/ && $let =~ /a/i) {$let = 'a:';}
      if ($prevlet =~ /[msgd]/ && $let =~ /u/i) {$let = 'u:';}
      if ($let =~ /a/i) {$let = 'a:';}
    }
    
    my $prvl = $prevlet;
	  $prvl =~ s/\://;
	  if ($prvl && $let =~ /$prvl/) {$phostring .= "#\n";}  

	  if (vowel($let)) { 
      if ($voicecolumn =~ /magyar/i) {$let =~ s/q/2/i;}
      if ($neuma) {$phostring .= setneuma($neuma, $let, $prevlet, $acttime, $pitchflag);}
      else {
	  	  my $atime = $lettime * $vowelmult * $mult;
        $phostring .= "$let $atime" . setvfreq(100, $actfreq, 0) . "\n";    
		  }
	  } elsif ($let eq ' ')	{ $phostring .= "\n"; next;}

	  else {
		 my $lt = ($let =~ [bdprk]) ? floor($lettime / 2) : $lettime;
		 $phostring .= "$let $lt \n";
	  }
	  $prevlet = $let;
      $prevfreq = $actfreq;
	}
  }
  } 
  return $phostring;
}

#*** getdo($metastring) {
# retuns ($doline, $dofreq) finding the clef and the tenor
# keyfreq is options parameters
sub getdo {
  my $metastring = shift;  
  my @linetoind = (-1,0,2,4,5,7,9,11,12,14,16,17); #ti, do, re ... ti do, re mi; on lines = 2-8
  my $tenor = 8;
  if ($metastring =~ /clef(.*?,)/) {$clef=$1;}   
  if ($metastring =~ /,\s*([0-9])t\s*,/i) {$tenor = $1;}
  if ($clef =~ /\=([0-9]+)/) {$doline = $1;}
  if ($clef =~ /fa/i) {$doline += 4;}
  my @clef = split('=', $clef);
  my $clefmult = $clef[2];
  if (!$clefmult) {$clefmult = 1.0;}
  $syllabletime = ($clef[3] > .5) ? $basetime * $clef[3] : $basetime;   
  
  $tenor -= ($doline - 8);
  $dofreq = sprintf("%2f", 2 * $keyfreq / (2 ** ($linetoind[$tenor] / 12)) * $clefmult); 
  return ($doline, $dofreq);
}


#*** getfreq($noteline, $be, $pitchflag)
# returns the cromatic frequency value 
# calculated from the line number and the input
sub getfreq {
  my $linenum = shift;       
  my $be = shift;
  my $pitchflag = shift;    

  my @linetoind = (-1,0,2,4,5,7,9,11,12,14,16,17); #ti, do, re ... ti do, re mi; on lines = 2-8
  
  $linenum -= ($doline - 8);
  if (!$be) {$be = 0;}  
  my $n = $linetoind[$linenum] - $be;  
  if ($linenum < 0) {$n = $linetoind[$linenum + 8] - 12 - $be;}
 
  my $freq = sprintf("%0.2f", $dofreq / 2 * 2 ** ($n / 12));   
  my $pmult = ($pitchflag) ? -$pitchdiff : $pitchdiff;
  
  return $freq + $pmult;
}

#*** setneuma($neuma, $let, $prevlet, $pitchflag);
# converts the neuma-vowel par into a pho file line, returns the result
# uses the common $prevlet variable 
sub setneuma {
  my $neuma = shift;
  my $let = shift;
  my $prevlet = shift;
  my $acttime = shift;
  my $pitchflag = shift;

  if ($let !~ /:/ && $let =~ /([a-z])/i) {$let = lc($1) . ':' . $'; }

  if ($voicecolumn =~ /Latin/i && $prevlet =~ /s/i && $let =~ /a/i) {$let = 'a';}
  
  my @neuma = split('~', $neuma);
  
  
  my $div = @neuma; 
  while ($neuma =~ /\./g) {$div += .5;}
  my $atime = floor($acttime * $div * 3 / 4);
  my $perc = floor(100/$div);
  my $str = "$let $atime ";
  my $sumperc = 0;
  
  my $item;
  my $i;
  my $oldsumperc = 0;
  for ($i = 0; $i < @neuma; $i++) {
	 my $item = $neuma[$i];
	 my $n;
	 if ($item =~ /^\s*([0-9]+)/) {$n = $1;}
	 else {next};
	 my $mult = 1;
	 my $be = ($item =~ /\-/) ? 1 : 0;
	 $actfreq = sprintf("%6.2f", getfreq($n, $be, $pitchflag)); 
     $nextfreq = $actfreq;
     while ($i < @neuma - 1) {
	   my $nextitem = $neuma[$i + 1];	
	   my $nn = 0;
	   if ($nextitem =~ /^\s*([0-9]+)/) {$nn = $1;}
	   if (!$nn || $nextitem =~ /b/i) {last;}
	   my $nbe = ($nextitem =~ /\-/) ? 1 : 0;
	   $nextfreq = sprintf("%6.2f", getfreq($nn, $nbe, $pitchflag)); 
	   last;
	 }
   if ($item =~ /\.\./) {$mult = 2;}
   elsif ($item =~ /\./)  {$mult = 1.5;}
   elsif ($item =~ /a/i) {$mult = 1.25;}
   $sumperc += $mult * $perc;
   if ($i >= @neuma - 1) {$sumperc = 100;}
   $str .= setvfreq($sumperc, $actfreq, $oldsumperc);
   $oldsumperc = $sumperc;
   $prevfreq = $actfreq;
   }
   return "$str\n";
}

#*** setvfreq($sumperc, $actfreq, $oldsumperc)
# returns the vibrating vowelfreq using
# $vowelmod (0-20) from chant parameters
# $prevfreq, $nextfreq set outside as our
sub setvfreq {
  my $sumperc = shift;
  my $actfreq = shift;
  my $oldsumperc = shift;

  if (!$prevfreq) {$prevfreq = $actfreq;}
  my $t1 = floor($sumperc * $vowelmod /100 + .5);
  my $t2 = $sumperc - $t1;
  $t1 += $oldsumperc;
  my $p1 = sprintf("%.2f", $actfreq + ($prevfreq - $actfreq) / 3);
  my $p2 = sprintf("%.2f", $actfreq + ($nextfreq - $actfreq) / 3);
  my $str = " $t1 $p1 $t2 $actfreq $sumperc $p2";
  return $str;
}

#*** playphorut($phostring)
# saves phostring with and sends it to phoplayer.exe
sub playphorut {
  my $phostring = shift;

  if (open(OUT, ">$datafolder/tmp/a.pho")) {
    print OUT $phostring;	
	close OUT;
	return phoproc("$datafolder/tmp/a.pho");

  }
}

#*** phoproc($phoname);
# Creates a process for phoplayer.exe
# and executes it with the set of parameters
# until end or 'stop pho ' abort is requested
sub phoproc {
  if ($phoobj) {$phoobj->Kill(0);  Win32::Sleep(10);}  #select(undef,undef,undef,.1);}

  my $phoname = shift;
  	 
  my $stereo = 	($mono) ? 'mono' : 'stereo';
  my $phout;
  my $dfolder="$datafolder/tmp";
  $dfolder =~ s/\//\\/g;  
  my $phodir = $phoplayer;             
  $phodir =~ s/\\phoplayer\.exe//; 
  my $voicebase = ($voicecolumn =~ /Magyar/i) ? 'hu1' : 'la1';    
  Win32::Process::Create($phoobj, $phoplayer,
    "phoplayer database=$voicebase voice=\"16000 $stereo\" " .
	  "noerror=yes " .
	  "vol=1.0 pitch=1.0 time=1.0 " . 
    "/F=A8 /F=U8 " .
    "/O=\"$dfolder\\w.wav\" /T=wav " .
    "$phoname", 0, 
    NORMAL_PRIORITY_CLASS, 
    $phodir)|| die ErrorReport();    		   
  $mwf->focus();
  $phosuspend = 0;
  $killed = 0;
  my $r = 0;
  while ($phoobj && !$r && !$killed) {
    $r = $phoobj->Wait(10);
    $mwf->update();
  }
  if ($killed) {return;}

  if (-e "$mbrfolder/sound.bat") {
    chdir ("$mbrfolder");
    Win32::Process::Create($phoobj, 'sound.bat', 
      "sound.bat $dfolder\\w.wav", 0,
      NORMAL_PRIORITY_CLASS, 
      "$mbrfolder")|| die ErrorReport();    		   
    my $r = 0;			   
    while ($phoobj && !$r && !$killed) {
      $r = $phoobj->Wait(10);
      $mwf->update();
    }
  } else {  Win32::Sound::Play("$dfolder\\w.wav"); }

  if ($phoobj) {$phoobj->Kill(0);  Win32::Sleep(10);}  #select(undef,undef,undef,.1);}
  $phoobj = '';

  $mwf->focus();
}

#*** ErrorReport()
# die callback for creating a process
sub ErrorReport {
    print Win32::FormatMessage( Win32::GetLastError() );
}

#*** phosuspend()
# called by pressing F5
# suspend a process, currently does not works
sub phosuspend { 
  if (!$phoobj || $phosuspend) {return;}
  $phoobj->Suspend();	 
  $phosuspend = 1;
}

#*** phoresume()
# called by pressing F6
# resume a process, currently does not works
sub phoresume { 
  if (!$phoobj || !$phosuspend) {return;}
  $phoobj->Resume();
  $phosuspend = 0;
}

#*** phokill
# called by pressing F8 or clicking Stop pho
# Kills a process a process, deletes the highlight
sub phokill {
  $killed = 1;	  
  $textwidget->tagDelete("grey");
  if (!$phoobj) {return;}
  $phoobj->Kill(0); #Win32::Sleep(100);  #select(undef,undef,undef,.1);
  $phoobj = '';
  $mwf->focus();
}

# SHOW NOTES
#*** show_notes($text)
# if chanted and text contains {: :} tags the notes are displayed
sub show_notes {	 
  my $text = shift;	 

  if ($voicecolumn !~ /chant/i || $text !~ /\{\:[a-z0-9_\- ]+\:\}/i) {return ('', 0);}
  my $lwidth = floor($mw->width * .8); 
  my $height = 50;
  
  my $cell = $middleframe->Canvas(-background=>$bgcolor, 
    -width=>$lwidth, -height=>$height, ,-borderwidth=>0,
    -highlightthickness=>0, -relief=>'flat'); 	 #$border, -relief=>'solid'
  $totalheight += 3;
  $noteheight = 3;

  my $tone;
  while ($text =~ /\{\:(.*?)\:\}/g) {
    $tone = $1;    
 	if (!$tone || $tone !~ /[a-z0-9]/i) {next;}
	setnotes($cell, $tone);
  }
  return ($cell, $noteheight);
}


#*** setnotes($canv, $x, $tonefile, 
#loads $tonefile and generates the image of notes into $canv canvas, starting at startpos
sub setnotes {
  $canv1 = shift;
  my $tonefile = shift;
  my $x;

  @texttone = splice(@texttone, @texttone);
  my $texttone = '';                                   
  if (open (INP, "$datafolder/tones/$tonefile.txt")) {  
    my @line;
    while ($line = <INP>) {
      if ($line !~ /\,\s*$/) {$line .= ',';}
      $texttone .= $line;
      push (@texttone, $line);
    }
    close INP;
    my $fontitem = '{Arial} 8 italic';
    $midfreq = midfreq($texttone);
	my $dotext = "$tonefile :\n($midfreq)";	 
	
	$canv1->createText(5, 10, -text=>$dotext, -anchor=>'nw', -font=>$fontitem, -fill=>'blue');
	$x = $mw->fontMeasure($fontitem, $dotext) + 10;
  } else {
    $canv1->createText(5, 15, -text=>"$tonefile tonefile is missing from tones folder",
     -anchor=>'nw', -font=>"{Arial} 10", -fill=>'red');
	  return;
  }

  my $row = 1;

  $nlstart = $x;
  my $notewidth = $mw->width * .8;
  
  
  $canv1->createRectangle($x, 2, $notewidth-10, 48, -fill=>white, -outline=>white); 
  foreach $y (12,22,32,42) {
    $canv1->createLine($x, $y, $notewidth-10, $y,-fill=>black,-width=>1);
  }
  
  makekey(1, $texttone[0], $x);

  my @notes = split(',', $texttone); 
  $x += 15;
  our $xstep = 15;
  
  shift(@notes);
  foreach $note (@notes) {
	if (!$note || $note =~ /^\s*$/) {next;}
	my @note = split('~', $note);
	if (($x + 6 * @note + 10) > ($notewidth - 10)) {
	  $row++; 
	  $height = $row * 50;
	  $totalheight += 3;
	  $canv1->configure(-height=>$height);
      my $a = ($row - 1) * 50;
      $canv1->createRectangle($nlstart, 2+$a, $notewidth-10, 48+$a, -fill=>white, -outline=>white); 
	  foreach $y (12+$a ,22+$a,32+$a,42+$a) {
        $canv1->createLine($nlstart, $y, $notewidth-10, $y,-fill=>black,-width=>1);
      }

	
	  makekey($row, $texttone[0], $nlstart); 
	  $x = $nlstart+25;
	}
		
	if (@note == 1) {
  	  if ($note =~ /b/) {	 
	    $x += $xstep - 6;
        #if ($row > 1 && $x < 35) {$row--; $x = $notewidth -13;}
	    makepause($row, $x, $note); 
	    $x += $xstep - 6;
	    next;
	  }

	  makenote($row, $x, $note, 1); 
	  if ($note =~ /-/) {$x += 8;}
	  if ($note =~ /\.\./) {$x += 6;}
	  if ($note =~ /\([0-9]+\)/ || $note =~ /t/i) {$x += 16;}

	  $x += $xstep;
	} elsif (@note == 2 && getpitch($note[0]) != getpitch($note[1])) {
	  if (getpitch($note[0]) < getpitch($note[1])) {
	    makenote($row, $x, $note[0], 1);
		if ($note[0] =~ /-/ && $note[1] !~ /-/) {$x += 6;}
		makenote($row, $x, $note[1], 1);
		if ($note[0] =~ /-/ || $note[1] =~ /-/) {$x += 6;}
		vline($row, $x+6, getpitch($note[1]), getpitch($note[0]));
   	    if ($note[0] =~ /\.\./ || $note[1] =~ /\.\./) {$x += 6;}
		$x += $xstep;
	  } else {
	    makenote($row, $x, $note[0], 1);
		if ($note[0] =~ /-/) {$x += 6;}
		vline($row, $x+6, getpitch($note[0]), getpitch($note[0])-3);
		if ($note[0] =~ /\.\./) {$x += 6;}
		if ($note[0] =~ /-/) {$x += 6;}
		makenote($row, $x+6, $note[1], 1);
		if ($note[1] =~ /\.\./) {$x += 6;}
		$x += $xstep + 6;
	  } 
	} else {
	   foreach $nt (@note) { 
	     if ($nt =~ /b/i) {
		   if ($row > 1 && $x < 35) {$row--; $x = $notewidth -13;}
	       makepause($row, $x, $note);
		   $x += 3; 
		 } else {
		   makenote($row, $x, $nt, 2); 
 		   if ($nt =~ /\.\./) {$x += 6;}
	       if ($nt =~ /-/) {$x += 6};
	       $x += 6;
	     }
	   }
	   $x += $xstep-6;
	}
  }
  #$canv1->createRectangle($x, 2, $notewidth-10, 48, -fill=>$bgcolor, -outline=>$bgcolor); 
  if ($row > 1) {$x = $notewidth;}
  $canv1->configure(-width=>$x);
}

#*** getpitch
#get and returns the linennumber from an ASCII note string
sub getpitch {
  my $nt = shift;
  if ($nt =~ /([0-9]+)/) {return $1;}
  return 0;
}

#makepause($row, $x, $nt
#draws break bars to the requested row, x position and type
#nt = [1-4]m for the different bars
sub makepause {
  my $row = shift;
  my $x = shift;
  my $nt = shift;	 

  my $p = getpitch($nt);  
  if ($p >= 4) {vline($row, $x, 8, 2); vline($row, $x+2, 8, 2);}
  elsif ($p == 3) {vline($row, $x, 8, 2);}
  elsif ($p == 2)  {vline($row, $x, 7, 3);}
  else {vline($row, $x, 9, 7);}
}

#*** makenote($note, $x, $nt, $flag
#draws the neuma to the requested row, x position and type
#structure of nt: <linenumber>[-][afptvq][.][.]	 (for vq flag=0)
#$flag: 1=square note, 0=diamond
sub makenote {
  my $row = shift;
  my $x = shift;
  my $nt = shift;
  my $flag = shift;

  my $line = getpitch($nt);
  if ($nt =~ /-/) {benote($row, $x, $line); $x += 8;}
 
  if ($nt =~ /\([0-9]\)/ || $nt =~ /t/i) {
    square($row,$x, $line); #  emptysquare($row, $x+9,$line);} # emptysquare($row, $x+13, $line);}
    makedot($row, $x + 2, $line, 2);
    makedot($row, $x + 8, $line, 2);
    makedot($row, $x + 14, $line, 2);
  } elsif ($flag == 1) {
  	if ($note =~ /f/i) {emptysquare($row, $x, $line);}
	else {square($row, $x, $line)}
  } else {diamond($row, $x, $line);}
  if ($nt =~ /a/i) {makeaccent($row, $x, $line);}
  if ($nt =~ /\.\./) {makedot($row, $x, $line, 2);} 
  elsif ($nt =~ /\./) {makedot($row, $x, $line, 1);} 

}

#*** makekey($row, $tone, $x)
#makes a do or fa key according to $texttone[0] line to the requested row
sub makekey {
  my $row = shift;
  my $tone = shift;
  my $x = shift; 
  
  if ($tone =~ /clef(do|fa)\=([0-9]+)/) {
    my $key = $1;
	my $line = $2;	
	
	if ($key =~ /do/) {
	  square($row, $x, $line-1); 
	  square($row, $x, $line+1); 
	  vline($row, $x, $line+1, $line-1);
	}
	else { 
	  square($row, $x, $line); 
	  vline($row, $x+6, $line, $line-2); 
	  square($row, $x+6, $line-1); 
	  square($row, $x+6, $line+1);}
  }
}

#*** square($row, $x, $num);
# draws a filled rsquare to the requested row, x and linenum position
sub square {
  my $row = shift;
  my $x = shift;
  my $num = shift;
						 
  my $base = $row * 50 - 1;
  my $y = $base - 5 * $num;	 
  $canv1->createRectangle($x, $y, $x+6, $y+6, -fill=>'black', -outline=>'black');
}

#*** vline($row, $x, $num1, $num2)
# draws a bar to the requested row and x position betweem num1 and num2 linepositions
sub vline {
  my $row = shift;
  my $x = shift;
  my $num1 = shift;
  my $num2 = shift;

  my $base = $row * 50 - 1;
  my $y1 = $base - 5 * $num1 + 3;	
  my $y2 = $base - 5 * $num2 + 3;	

  $canv1->createLine($x, $y1, $x, $y2, -fill=>'black');
}

#*** makeaccent($row, $x, $nuk);
# draws a short accent bar to the requested row and x position above the given linenum position
sub makeaccent {
  my $row = shift;
  my $x = shift;
  my $num = shift;
					
  my $base = $row * 50 - 1;
  my $y = $base - 5 * $num;
  $canv1->createLine($x + 3, $y - 2, $x + 4, $y - 7, -fill=>'black')
}

#*** makedot($row, $x, $num, $flag)
# darws a dot after ($lag==2) or above (otherwise) the given linennum position
# to the reqestted row and x position
sub makedot {
 my $row = shift;
 my $x = shift;
 my $num = shift;
 my $flag = shift;
 
 my $base = $row * 50 - 1;
 my $y = $base - 5 * $num;
 
 if ($flag == 2) {$canv1->createOval($x+8, $y + 1.5, $x + 11, $y + 4.5, -fill=>'black');}
 else {$canv1->createLine($x, $y-2, $x+6, $y - 2, -fill=>'black');}
}

#*** diamond($row, $x, $num)
# draws a diamond do the requested row, x and linenum position
sub diamond {
  my $row = shift;
  my $x = shift;
  my $num = shift;

  my $base = $row * 50 - 1;
  my $y = $base - 5 * $num;
  $canv1->createPolygon($x, $y+3, $x+3, $y, $x+6, $y+3, $x+3, $y+6, -fill=>'black', -outline=>'black');
}

#*** emptysquare($row, $x, $num)
# draws an empty square do the requested row, x and linenum position
sub emptysquare {
  my $row = shift;
  my $x = shift;
  my $num = shift;

  my $base = $row * 50 - 1;
  my $y = $base - 5 * $num;
  $canv1->createRectangle($x, $y, $x+6, $y+6, -outline=>'black');
}

#*** benote($row, $x, $num)
# draws a be sign do the requested row, x and linenum position
sub benote {
  my $row = shift;
  my $x = shift;
  my $num = shift;

  my $base = $row * 50 - 1;
  my $y = $base - 5 * $num;   
  $canv1->createOval($x, $y, $x+6, $y+6, -outline=>'black', -width=>1);
  $canv1->createLine($x, $y, $x, $y-9, -fill=>'black')
}

sub midfreq {  
 my $tone = shift;
 ($doline, $dofreq) = getdo($tone);
 my @tone = split(',', $tone);
 my $sumnotes = 0;
 my $numnotes = 0;
 my $speed = 1.0;
 my $aline;
 foreach $p (@tone) {
   if ($p =~ /clef/i) {
     my @p = split('=', $p);
     if ($p[3]) {$speed = $p[3];}
   }
   if ($p =~ /(clef|b)/) {next;}

   if ($p =~ /~/) {
     @p = split('~', $p);
     foreach $p1 (@p) {
       if ($p1 =~ /([0-9]+)/) {
         $sumnotes += $1;
         $numnotes++;
       }
     }
     next;
   }
   if ($p =~ /([0-9]+)/) {
     $sumnotes += $1;
     $numnotes++;
   }
 }
 $aline = floor($sumnotes / $numnotes + .5);
 if ($tone =~ /([0-9]+)\-*t/i) {$aline = $1;}

 
 my $afreq = floor(getfreq($aline, 0, 0) + .5);
 $speed = floor(60000 / (3 * $basetime * $speed));
 return "$afreq=$speed";
}