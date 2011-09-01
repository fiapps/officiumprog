#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-11-04
# WEB dialogs

#use warnings;
#use strict "refs";
#use strict "subs";

my $a = 4;

#*** savesetuphash($name, \%setup)
# saves the referenced setup hash modified by each dialog call
# into $name.setup file
# called by ondestroy callback of MainWindow
sub savesetuphash {
  my $name = shift;
  my $setup = shift;
  my %setup = %$setup; 
  if (open (OUT, ">$datafolder/$name.setup")) {
     my ($key, $value);
	 foreach $key (sort keys %setup) {	
	    print OUT '[' . $key . "]\n";
		$value = $setup{$key};	
		$value =~ s/\n//g;
		$value =~ s/;;/;;\n/g; 
		print OUT "$value\n";  
     }
	 close OUT;
  }
}


#*** htmlHead($title, $flag)
# generated the standard head with $title
sub htmlHead {
  my $title = shift;
  if (!$title) {$title = ' ';}
  $htmltext = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n" .
  "<HTML><HEAD>\n" .
  "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=ISO-8859-1\">" .
  "<META NAME=\"Resource-type\" CONTENT=\"Document\">\n" .
  "<META NAME=\"description\" CONTENT=\"Divine Office\">\n" .
  "<META NAME=\"keywords\" CONTENT=\"Divine Office, Breviarium, Liturgy, Traditional, Zsolozsma\">\n" .
  "<META NAME=\"Copyright\" CONTENT=\"Like GNU\">\n" .
  "<META NAME=\"Author\" CONTENT=\"$version\">\n" .
  "<META NAME=\"Publisher\" CONTENT=\"Divinumofficium.com\">\n" .
  "<TITLE>$title</TITLE>\n" .
  "</HEAD>";
}

#*** setfont($font, $text)
# input font description is "[size][ italic][ bold] color" format, and the text
# returns <FONT ...>$text</FONT> string
sub setfont {
  my $istr = shift;
  my $text = shift;
  
  my $size = ($istr =~ /^\.*?([0-9\-\+]+)/i) ? $1 : 0;
  my $color = ($istr =~ /([a-z]+)\s*$/i)  ? $1 : '';
  if ($istr =~ /(\#[0-9a-f]+)\s*$/i || $istr =~ /([a-z]+)\s*$/i) {$color = $1;}

  my $font = "<FONT ";
  if ($size) {$font .= "SIZE=$size ";}
  if ($color) {$font .= "COLOR=\"$color\"";}
  $font .= ">";
  if (!$text) {return $font;}

  my $bold = '';
  my $bolde = '';
  my $italic = '';
  my $italice = '';
  if ($istr =~ /bold/) {$bold = "<B>"; $bolde = "</B>";}
  if ($istr =~ /italic/) {$italic = "<I>"; $italice = "</I>";}
  return "$font$bold$italic$text$italice$bolde</FONT>";
}


#*** setcross($line)
# changes +++, ++ + to crosses in the line
sub setcross {
  my $line = shift;
  return $line;
}

#*** setcell($text1, $lang1);
# output the content of the cell
sub setcell {
  my $text = shift;
  my $lang = shift; 
 
 
  if (!$accented) {$text = deaccent1($text);}
  my $width = ($only) ? 100 : 50;
  if (columnsel($lang)) {
    $searchind++; $htmltext .=  "<TR>";
    if ($notes && $text =~ /\{\:(.*?)\:\}/) {
      my $notefile = $1;
	  my $columns = ($only) ? 1 : 2;
	  $notefile =~ s/^pc/p/;
	  $imgu = ($onefile) ? $imgurl1 : $imgurl;
	  $htmltext .= "<TR><TD COLSPAN=$columns WIDTH=100% $background VALIGN=MIDDLE ALIGN=CENTER>\n" .
	    "<IMG SRC=\"$imgu/$notefile.gif\" WIDTH=100%></TD></TR>\n";
    }
  }
  
    # handle chant
    my $ttext = $text;
    $text = '';
    $ctext = '';   
    while ($voicecolumn =~ /chant/i && $voicecolumn =~ /$lang/i && $ttext =~ /\{\:(.*?)\:\}/) { 
      $tonefile = $1;         
      $text .= $`;
      $ttext = $';
      if (!$tonefile) {next;}
      if ($ttext =~ /\{\:\:\}/) {$ctext = $`; $ttext = $';}
      else {$ctext = $ttext; $ttext = '';}
      my $wavfilename = substr($hora,0,1) . '-' . substr($lang, 0,1) . "$searchind-$tonefile";
	  my $reffilename = ($onefile) ? "$month_day/$wavfilename" : $wavfilename;
      
      $text .= "<A HREF=\"$reffilename.wav\" TARGET=\"_NEW\"> chant </A>$ctext";
      $ctext =~ s/\<.*?\>//g;
	    $ctext =~ s/\(.*?\)//g;
	    $ctext =~ s/\[.*?\]//sg;
      $ctext =~ s/^\s*//;
	    $ctext =~ s/(R\.br\.*|R\.|V\.|Ant\.|Benedictio\.* |Absolutio\.* )//sg;
	    $ctext =~ s/[0-9]+\:*[0-9]*//sg;
	    $ctext =~ s/^\_\s*//mg;
	    makewav($ctext, $tonefile, $wavfilename);
    }
    $text .= $ttext;
  
  
  $text =~ s/\{\:.*?\:\}//g;
  $text =~ s/\_/ /g;
  $text =~ s/[%`]//g;

  $text =~ s/wait[0-9]+//gi;

  $tdtext2 = '';
  if ($column == 1) {$tdtext1 = $text;}
  else {$tdtext2 = $text;}
  
  if ($column == 2 && !$only) {
    my ($b1, $b2) = longtd($tdtext1, $tdtext2);
	@tdtext1 = @$b1;
	@tdtext2 = @$b2;  
    my $item;
    my $i = 0;
	while ($i < @tdtext1 && $i < @tdtext2) {
	  $item = $tdtext1[$i];
      if ($i > 0) {$htmltext .= "<TR>";}
	  $htmltext .="<TD $background VALIGN=TOP ALIGN=LEFT WIDTH=45%>";  
      $htmltext .=  setfont($blackfont,$item) . "</TD>\n";
  
      $item = $tdtext2[$i];
      $htmltext .="<TD $background VALIGN=TOP ALIGN=LEFT WIDTH=45%>";  
      $htmltext .=  setfont($blackfont,$item) . "</TD>\n";
      if ($extracolumn) {
	    $htmltext .="<TD $background VALIGN=TOP ALIGN=Center WIDTH=10%>";  
        $htmltext .=  "$filler</TD>\n";
      }
	  if ($filler && $filler ne ' ') {$filler = ' ';}

      $i++;
	}
	@tdtext1 = splice(@tdtext1, @tdtext1);
    @tdtext2 = splice(@tdtext2, @tdtext2);   
    $htmltext .= "</TR>\n";
  }
  
  if ($only) {
    $htmltext .=  "<TD $background VALIGN=TOP WIDTH=$width% ID=L$searchind>"; 
    $htmltext .=  setfont($blackfont,$text) . "</TD>\n";
    if ($only || !columnsel($lang)) {$htmltext .= "</TR>\n";} 
  }
} 

#*** topnext_Cell() 
#prints T N for positioning
sub topnext_cell {
    my $lang = shift;
    my @a = split('<BR>', $text1);
    if (@a > 2 && $expand !~ /skeleton/i) {return topnext($lang); }
}

sub topnext {
  my $lang = shift;
  my $str = "<FONT SIZE=1 COLOR=green><DIV ALIGN=right>";
  if (columnsel($lang)) {
    $str .= "<A HREF=# onclick=\"setsearch($searchind);\">Top</A>&nbsp;&nbsp;";
    $str .= "<A HREF=# onclick=\"setsearch($searchind+1);\">Next</A>";
  } else {$str .= "$searchind";}
  $str .=  "</DIV></FONT>\n";
  return $str;
}
    
#*** table_start
# start main table
sub table_start {
  $htmltext .= "<TABLE BORDER=0 ALIGN= CELLPADDING=0 CELLSPACING=$border BGCOLOR='$framecolor' WIDTH=99%>";

  our @tdtext1 = splice(@tdtext1, @tdtext1);
  our @tdtext2 = splice(@tdtext2, @tdtext2);
  our $tdtext1 = '';
  our $filler = '';
  my $i;
  if ($extracolumn) {for ($i = 0; $i < $extracolumn; $i++) {$filler .= '.';}}
   

}

sub ante_post {
  return;
}


#table_end()
# finishes main table
sub table_end {
  $htmltext .= "</TABLE><BR>";
}

#*** linkcode($name, $ind, $lang, $disabled)
# set a link line
sub linkcode {
  return '';
  my ($name, $ind, $lang, $disabled) = @_;
  return "<INPUT TYPE=RADIO NAME=link $disabled onclick='linkit(\"$name\", $ind, \"$lang\");'>";
}

#*** linkcode1()
# sets a collpse radiobutton
sub linkcode1 {
   return '';
   return "&nbsp;&nbsp;&nbsp;" .
     "<INPUT TYPE=RADIO NAME=collapse onclick=\"linkit('','10000','');\">\n";
}


#*** makewav($text, $tfile, $wavfilename)
# converts text to meta -> pho format and and to wav using phoplayer.exe
sub makewav {
  if ($Hk < 3) {return;}
  
  my $text = shift;    
  my $tfile = shift;   
  my $wavfilename = shift;  
  my $tone = ''; #shift; 
  my $psalmline = 0; #shift;
  my $lineind = ''; #shift;

  $tfile =~ s/^pc/p/;
  if (open (INP, "$datafolder/tones/$tfile.txt")) {
    $tone = '';
	  my $line;
	  while ($line = <INP>) {$tone .= $line;};      
	  close INP;
  }	 else {print "$datafolder/tones/$tfile.txt cannot open"; return;}
        
  $chanttype = ($tfile =~ /^H\-/) ? 'Hymn' : ($tfile =~ /^p/i) ? 'Psalm' : 'Syllabic';
  
  our $doline = 8;
  our $clef = 'do=8';
  our $texttone = $tone;

  my @ctext = split("\n", $text);
  my $text = '';
  my $ind;
  for ($ind = 0; $ind < @ctext; $ind++) {
    my $p1 = $ctext[$ind];
	  if (!$p1 || $p1 =~ /^\s*$/) {next;} 
    if ($chanttype =~ /^Psalm/i) {$p1 = psalmflex($p1);}
    $p1 = praepare($p1);
    $p1 = compose($p1, $chanttype, $tone, $ind, $ind);    
    $text .= playmetarut($p1, $ind & 1);  
    if (!$texttone) {last;}
  }

  $outfile = "$outdir/$year/$month_day/$wavfilename";
  if (open(OUT, ">$outfile.pho")) {
    print OUT $text;	
	close OUT;
  } else { print "$outfile.pho cannot open for output"; return;}

  if ($phoobj) {$phoobj->Kill(0);  Win32::Sleep(10);}  

  my $stereo = 	($mono) ? 'mono' : 'stereo';
  my $phout;
  my $dfile=$outfile;
  $dfile =~ s/\//\\/g;  

  our $phoplayer = "$mbrfolder/phoplayer.exe";
  $phoplayer =~ s/\//\\/g;    

  #my $phoplayer = "$mbrfolder/phoplayer.exe";
  #$phoplayer =~ s/\//\\/g;
  my $phodir = $phoplayer;
  $phodir =~ s/\\phoplayer\.exe//; 
 
  my $voicebase = ($voicecolumn =~ /Magyar/i) ? 'hu1' : 'la1';    
  Win32::Process::Create($phoobj, $phoplayer,
    "phoplayer database=$voicebase voice=\"16000 $stereo\" " .
    "noerror=yes " .
    "vol=1.0 pitch=1.0 time=1.0 " . 
    "/F=A8 /F=U8 " .
    "/O=\"$outfile.wav\" /T=wav " .
    "$outfile.pho", 0, 
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
  return 1;
}

sub deaccent1 {
  my $w = shift; 

 
  $w =~ s/á/a/g;
  $w =~ s/é/e/g;
  $w =~ s/ë/e/g;
  $w =~ s/í/i/g;
  $w =~ s/ó/o/g;
  $w =~ s/ú/u/g;
  $w =~ s/Á/A/g;
  $w =~ s/É/E/g;
  $w =~ s/Í/I/g;
  $w =~ s/Ó/O/g;
  $w =~ s/Ú/U/g;
  $w =~ s/æ/ae/g;
  $w =~ s/œ/oe/g;
  $w =~ s/Æ/Ae/g;
  $w =~ s/Œ/Oe/g; 
  $w =~ s/ý/y/g;
  $w =~ s/ö/o/g;
  $w =~ s/õ/o/g;
  $w =~ s/ô/o/g;
  $w =~ s/ü/u/g;
  $w =~ s/û/u/g;
  $w =~ s/Ö/O/g;
  $w =~ s/Ô/O/g;
  $w =~ s/Ô/O/g;
  $w =~ s/Ú/U/g;
  $w =~ s/Ü/U/g;
  $w =~ s/Û/U/g;
  $w =~ s/’/'/g;

  return $w;
}

sub longtd {
 
  my $a1 = shift; 
  my $a2 = shift; 

  my @a1 = split('<BR>', $a1);
  my @a2 = split('<BR>', $a2);
  my @b1 = splice(@b1, @b1);
  my @b2 = splice(@b2, @b2);
  my $i;
  my $lim = @a1;
  if (@a2 > $lim) {$lim = @a2;}
  
  for ($i = 0; $i < $lim; $i++) {
    my $b1 = $a1[$i];
	my $b2 = $a2[$i]; 
    if (length($b1) < $celllength && length($b2) < $celllength) {
	  if ($b1) {push(@b1, $b1);}
	  if ($b2) {push(@b2, $b2);}  
	  next;
	}
	my @c1 = split('|', $b1); 
	my @c2 = split('|', $b2); 
    my $flag = 0;
	my $i = 0;
	my $s = '';

	while ($i < @c1) {
	  my $c = $c1[$i];
	  $i++;
      if (!$flag && length($s) > $celllength && $c eq '<' && $s) {push(@b1, $s); $s = '';}
	  if ($c eq '<' && $c1[$i] ne '/') {$flag++;}
	  if ($c eq '<' && $c1[$i] eq '/' && $flag) {$flag--;}
	  $s .= $c;
	  if ($flag) {next;}
	  if (($c =~ /[.?]/ && length($s) > $celllength && $i < @c1-1 && $c1[$i] eq ' ' && $c1[$i+1] =~ /[A-Z"]/) ||
	   ($c =~ /[,;:]/ && length($s) > $celllength)) {push(@b1, $s); $s = '';}
    }
	if ($s) {push(@b1, $s);}

	$i = 0;
	$s = '';
	$flag = 0;
	while ($i < @c2) {
	  my $c = $c2[$i];
	  $i++;
      if (!$flag && length($s) > $celllength && $c eq '<' && $s) {push(@b2, $s); $s = '';}
	  if ($c eq '<' && $c2[$i] ne '/') {$flag++;}
	  if ($c eq '<' && $c2[$i] eq '/' && $flag) {$flag--;}
	  $s .= $c;
	  if ($flag) {next;}
	  if (($c =~ /[.?]/ && length($s) > $celllength && $i < @c2-1 && $c2[$i] eq ' ' && $c2[$i+1] =~ /[A-Z"]/) ||
	   ($c =~ /[,;:]/ && length($s) > $celllength)) {push(@b2, $s); $s = '';}
    }
	if ($s) {push(@b2, $s);}
    
	while (@b1 < @b2) {push(@b1, ' ');}
	while (@b2 && @b2 < @b1) {push(@b2, ' ');}
  
  
  } 
  
  return (\@b1, \@b2);

}


