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
  "<META NAME=\"Resource-type\" CONTENT=\"Document\">\n" .
  "<META NAME=\"description\" CONTENT=\"Divine Office\">\n" .
  "<META NAME=\"keywords\" CONTENT=\"Divine Office, Breviarium, Liturgy, Traditional, Zsolozsma\">\n" .
  "<META NAME=\"Copyright\" CONTENT=\"Like GNU\">\n" .
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
  my $csubst = ''; #"<IMG SRC=$htmlurl/cross3.gif ALIGN=BASELINE ALT=cross3>";
  $line =~ s/\+\+\+/$csubst/g;
  $csubst = ''; #"<IMG SRC=$htmlurl/cross2.gif ALIGN=BASELINE ALT=cross2>";
  $line =~ s/\+\+/$csubst/g;
  $csubst = ' '; #"<IMG SRC=$htmlurl/cross1.gif ALIGN=BASELINE ALT=cross1>";
  $line =~ s/ \+ / $csubst /g;
  return $line;
}

#*** setcell($text1, $lang1);
# output the content of the cell
sub setcell {
  my $text = shift;
  my $lang = shift; 
  
  my $width = ($only) ? 100 : 50;
  if (columnsel($lang)) {
    $searchind++; $line .=  "<TR>";
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
      
      $text .= "<A HREF=\"$wavfilename.wav\" TARGET=\"_NEW\"> chant </A>$ctext";
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
  $htmltext .=  "<TD $background VALIGN=TOP WIDTH=$width% ID=L$searchind>"; 
  $htmltext .=  setfont($blackfont,$text) . "</TD>\n";
  if ($only || !columnsel($lang)) {$htmltext .= "</TR>\n";} 
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
  $htmltext .= "<TABLE BORDER=0 ALIGN=CENTER CELLPADDING=8 CELLSPACING=$border BGCOLOR='$framecolor' WIDTH=80%>";
}

#antepost('$title')
# prints Ante of Post call
sub ante_post {
  return;
  my $title = shift;
  my $colspan = ($only) ? '' : 'COLSPAN=2';

  $htmltext .= "<TR><TD $background VALIGN=TOP $colspan ALIGN=CENTER>\n" .
   "<INPUT TYPE=RADIO NAME=link onclick='linkit(\"\$$title\", 0, \"Latin\");'>\n" .
   "<FONT SIZE=1>$title Divinum officium</FONT></TD></TR>";
}

#table_end()
# finishes main table
sub table_end {
  $htmltext .= "</TABLE><span ID=L$searchind></span>";
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

  $outfile = "$outdir/$year/$month-$day/$wavfilename";
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
