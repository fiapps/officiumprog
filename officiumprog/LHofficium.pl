#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 09-25-08
# Divine Office

package horas;
#1;
                        
#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FATAL=>qw(all);

our $padx = 10;
our $pady = 10;
our $widthperc = .99;
our $heightperc = .90;

use POSIX;
use FindBin qw($Bin);
use File::Basename;
use Time::Local;
#use DateTime;
use locale;

use Tk;
use Tk::Widget;
use Tk::widgets;
use Tk::Checkbutton;
use Tk::Scale;
use Tk::Dialog;
use Tk::Pane;
use Tk::Scrollbar;
use Tk::Radiobutton;
use Tk::Optionmenu;
use Tk::Text;
use Tk::ErrorDialog;
use Tk::Font;
use Tk::Table;

our $officium = 'officium.pl';
our $version = 'Divino Afflatu';

$iexplore = 'iexplore';

#***common variables arrays and hashes
#filled  getweek()
our @dayname; #0=Advn|Natn|Epin|Quadpn|Quadn|Pascn|Pentn 1=winner title|2=other title

#filled by getrank()
our $winner; #the folder/filename for the winner of precedence
our $commemoratio; #the folder/filename for the commemorated
our $scriptura; #the folder/filename for the scripture reading (if winner is sancti)
our $commune; #the folder/filename for the used commune
our $communetype; #ex|vide
our $rank; #the rank of the winner
our $laudes; #1 or 2
our $vespera; #1 | 3 index for ant, versum, oratio
our $cvespera; #for commemoratio
our $commemorated; #name of the commemorated for vigils
our $comrank = 0; #rank of the commemorated office

#filled by precedence()
our %winner; #the hash of the winner 
our %commemoratio; #the hash of the commemorated
our %scriptura; #the hash for the scriptura
our %commune; # the hash of the commune
our (%winner2, %commemoratio2, %commune2); #same for 2nd column
our $rule; # $winner{Rank}
our $communerule; # $commune{Rank}
our $duplex; #1=simplex-feria, 2=semiduplex-feria privilegiata, 3=duplex 
             # 4= duplex majus, 5 = duplex II classis 6=duplex I classes 7=above  0=none
our $sanctiname = 'Sancti';
our $temporaname = 'Tempora';
our $communename = 'Commune';

#*** collect standard items
require "dialogcommon.pl";
require "horascommon.pl";
require "horas.pl";
require "specials.pl";
require "specmatins.pl";
require "Hwebdia.pl";
require "Hsetup.pl";
require "Aedit.pl";
require "Acheck.pl";
require "tfertable.pl";

#get parameters
getini('Hhoras'); #files, colors

our $Hk = 1;
our $Tk = 0;
our $Ck = 0;
our $notes = 0;
our $missa = 0;
our $accented = 'accented';

our ($lang1, $lang2, $expand, $column);
our %translate; #translation of the skeleton label for 2nd language 
our ($voicecolumn, $doline, $keyfreq, $dofreq, $basetime,$voweltime, $vowelmod, $mono);

our $mw = MainWindow->new();

#internal script, cookies
our %dialog = %{setupstring("$datafolder/Hhoras.dialog")};
our %setup = %{setupstring("$datafolder/Hhoras.setup")};
eval $setup{general};
eval $setup{'parameters'};
eval $setup{'Chant'};	      
$testmode = ($testmode =~ /season/i) ? $testmode : 'regular';
$votive = 'proper';

our $command = '';
our $hora = $command; #Matutinum, Laudes, Prima, Tertia, Sexta, Nona, Vespera, Completorium
our $votive = 'proper';
our $expandnum = 0;
       
if ($geometry) {
  my $g = $geometry;
  $g =~ s/\+/x/;
  my @g = split('x', $g);
  if (($g[0] + $g[2]) > $mw->screenwidth || 
    ($g[1] + $g[3]) > $mw->screenheight) {$geometry = '';}
}

our $fullwidth = floor($mw->screenwidth * $widthperc);
our $fullheight = floor($mw->screenheight * $heightperc);
our $anteflag = 0;
if (!$geometry) {$geometry = $fullwidth . "x$fullheight+0+0";}
$mw->geometry($geometry);
$mw->configure(-title=>'Generate Offices');

$mw->configure(-background=>"#ffffdd", -height=>$fullheight, -width=>$fullwidth);
$mw->OnDestroy(\&finalsave);

$firstcall = 0;
our @command = splice(@command, @command);
mainpage();
$firstcall = 0;
MainLoop();


#*** mainpage();
# creates the opening and horas pages
sub mainpage {  
                
if ($firstcall == 1) {return;}
$firstcall = 1;
$mw->configure(-title=>"Generate Offices");
$error = '';
our $only = ($lang1 =~ /^$lang2$/) ? 1 : 0;
our ($priest, $width, $blackfont, $redfont, $smallblack, $smallfont, $titlefont,
  $black, $red, $blue);

if ($lang1 !~ /Latin/i && $voicecolumn =~ /Latin/i) {$voicecolumn = 'mute';}
if ($lang2 !~ /Magyar/i && $voicecolumn =~ /Magyar/i) {$voicecolumn = 'mute';}
if ($Hk < 3) {$voicecolumn = 'mute';}


 
$mwf = $mw->Scrolled('Pane', -scrollbars=>'osoe',
 -width=>$fullwidth, -height=>$fullheight, -background=>"#ffffdd")
 ->pack(-side=>'top', -padx=>$padx, -pady=>$pady);

our $datefrom = gettoday();
our $dateto = $datefrom;
our $outdir = "$Bin";

$labelfont = "{Arial} 12";
$framecolor = "#ffffdd";

#*** topframe
$topframe = $mwf->Frame(-background=>"#ffffdd")->pack(-side=>'top', -ipady=>50);
$topframe->Button(-text=>"Generate Offices",  -font=>$labelfont, -command=>sub{generate();})
  ->pack(-side=>'left', -padx=>$padx);
$topframe->Label(-text=>'From: ', -background=>"#ffffdd", -foreground=>'maroon')
  ->pack(-side=>'left', -padx=>$padx);
$topframe->Entry(-textvariable=>\$datefrom, -width=>10, -background=>"#ffffdd")
  ->pack(-side=>'left', -padx=>$padx);	   
$topframe->Label(-text=>' To: ', -background=>"#ffffdd", -foreground=>'maroon')
  ->pack(-side=>'left', -padx=>$padx);
$topframe->Entry(-textvariable=>\$dateto, -width=>10, -background=>"#ffffdd")
  ->pack(-side=>'left', -padx=>$padx);	   
$topframe->Label(-text=>' Into: ', -background=>"#ffffdd", -foreground=>'maroon')
  ->pack(-side=>'left', -padx=>$padx);
$topframe->Entry(-textvariable=>\$outdir, -width=>32, -background=>"#ffffdd")
  ->pack(-side=>'left', -padx=>$padx);	   

#*** bottomframe
$bottomframe = $mwf->Frame(-background=>"#ffffdd")->pack(-side=>'top', -ipady=>50);


$bframe2 = $bottomframe->Frame(-background=>"#ffffdd")->pack(-side=>'top', -pady=>10);

my 	@names = ('Expand', 'Version', 'Mode', 'Column2', 'Votive');
for ($i = 0; $i < @names; $i++) {
  $item = $names[$i];  
  $bframe2->Label(-text=>"$names[$i]", -borderwidth=>0, -font=>"{Arial} 10", 
     -foreground=>'maroon', -background=>"#ffffdd")
     ->grid(-column=>$i, -row=>0, -padx=>$padx, -pady=>$pady);
}

@optarray1 = ('all', 'psalms', 'nothing', 'skeleton');	 
$bframe2->Optionmenu(-options=>\@optarray1, -textvariable=>\$expand, #-background=>"#ffffdd", 
  -border=>1, -font=>$labelfont, -command=>sub{mainpage();})
   ->grid(-column=>0, -row=>1, -padx=>$padx, -pady=>$pady);

@versions = ('Trident 1570', 'Trident 1910', 'Divino Afflatu', 'Reduced 1955', 'Rubrics 1960', '1960 Newcalendar');
$bframe2->Optionmenu(-options=>\@versions,-textvariable=>\$version, #-background=>$framecolor,
   -border=>1, -font=>$labelfont, -command=>sub{mainpage();})
   ->grid(-column=>1, -row=>1, -padx=>$padx, -pady=>$pady);
                      
@optarray3 = ('Regular', 'Seasonal', 'Season', 'Saint', 'Common');
$bframe2->Optionmenu(-options=>\@optarray3,-textvariable=>\$testmode, #-background=>$framecolor,
  -border=>1, -font=>$labelfont, -command=>sub{mainpage();})
  ->grid(-column=>2, -row=>1, -padx=>$padx, -pady=>$pady);

opendir(DIR, $datafolder); 
@a = readdir(DIR);
close DIR;
@optarray4 = splice(@optarray4, @optarray4);
foreach $item (@a) {
  if ($item !~ /\./ && (-d "$datafolder/$item") && 
    $item =~ /^[A-Z]/ && $item !~ /(tmp|help)/i) {push(@optarray4, $item);}
}		
$bframe2->Optionmenu(-options=>\@optarray4,-textvariable=>\$lang2, #-background=>$framecolor,
   -border=>1, -font=>$labelfont, -command=>sub{mainpage();})
   ->grid(-column=>3, -row=>1, -padx=>$padx, -pady=>$pady);

@optarray5 = ('proper', 'hodie', 'Dedication', 'Defunctorum', 'Parvum B.M.V.');
$bframe2->Optionmenu(-options=>\@optarray5,-textvariable=>\$votive, #-background=>$framecolor,
   -border=>1, -font=>$labelfont,
   -command=>sub{mainpage();})
   ->grid(-column=>4, -row=>1, -padx=>$padx, -pady=>$pady);

$bframe3 = $bottomframe->Frame(-background=>"#ffffdd")->pack(-side=>'top', -pady=>$pady);

$bframe3->Button(-text=>'Options', -command=>sub{setuptable('parameters');})
  ->pack(-side=>'left', -padx=>$padx);

my $odir =$outdir;
$odir =~ s/\//\\/g;

$bframe3->Button(-text=>'Browse', -command=>sub{system("start explorer \"$odir\"");})
  ->pack(-side=>'left', -padx=>$padx);
$bframe3->Button(-text=>'Help',
  -command=>sub{system("start $iexplore \"$datafolder/Help/Hhelp.html\"");}) 
  ->pack(-side=>'left', -padx=>$padx, -pady=>$pady);  

$bottomframe->Label(-textvariable=>\$error, -background=>"#ffffdd", -foreground=>'red')
    ->pack(-side=>'top', -pady=>$pady);
$bottomframe->Label(-textvariable=>\$message, -background=>"#ffffdd", -foreground=>'maroon')
    ->pack(-side=>'top', -pady=>$pady);

$mwf->pack(-anchor=>'n');
$mwf->idletasks();
$firstcall = 0;
}  

sub errorTk {
  my $str = shift; 
  $mw->messageBox(-title=>'Error', -message=>$str, -type=>'OK');
}


#*** finalsave()
# called before exit
# saves horas.setup file with the current values
sub finalsave {
  setsetup('general', $expand, $version, $testmode, $lang2, 'proper', $accented);
  if ($savesetup) {
    savesetuphash('Hhoras', \%setup);
  }      
}


sub configure {
  my ($widget, $bgcolor, $fontline, $color) = @_;	 
  my ($font, $c) = setfont($fontline);
  if (!$color) {$color = $c;}	 
  $widget->configure(-font=>$font, -foreground=>$color, -background=>$bgcolor);
}

sub prevnext {
  my $inc = shift;
  my $date1 = shift;
  my ($month, $day, $year) = split('-', $date1);

  my $d= date_to_days($day,$month-1,$year);
  
  my @d = days_to_date($d + $inc);
  $month = $d[4]+1;
  $day = $d[3];
  $year = $d[5]+1900;     
  $date1 = "$month-$day-$year";
}


sub generate {
  my $maxnum = 0;
  our $date1 = $datefrom;
  while ($maxnum <= 366) {
    @horas = getdialogcolumn('horas','~',0);
    shift(@horas);
    pop (@horas);
    our ($month, $day, $year) = split('-', $date1);
    $outdir =~ s/\/\s*$//;
    if (!(d- "$outdir")) {mkdir("$outdir");}
    $month_day = "$month-$day"; 
	if ($votive =~ /(Dedication|Defunctorum|Parvum B.M.V.)/i) {$month_day = "$1$month_day"; ;}
	if (!(d- "$outdir/$year")) {mkdir("$outdir/$year");}
    if (!(d- "$outdir/$year/$month_day")) {mkdir("$outdir/$year/$month_day");}

    master($month_day);
    foreach $h (@horas) {
	  if ($votive =~ /Defunctorum/i && $h !~ /(Matutinum|Laudes|Vespera)/i) {next;}
	  generatehora($h, $date1);
	  if (open(OUT, ">$outdir/$year/$month_day/$hora.html")) {
        print OUT $htmltext;
        close OUT;
	  
	  } else {print "$outdir/$year/$month_day/$hora.html cannot open\n"; last;}
    }
    $maxnum++;
    if ($date1 eq $dateto) {last;}
    $date1 = prevnext(1, $date1);
  }
  $message = "Offices for $maxnum days are generated";
  $mw->update();
}

sub master {
   my $monthday = shift;
   my $title = "Master-$monthday";
   $hora = 'Laudes';
   precedence($date1); #fills our hashes et variables  
   $daycolor =   ($commune =~ /(C1[0-9])/) ? 'blue' :
     ($dayname[1] =~ /(Quattuor|Feria|Vigilia)/i) ? $black :
     ($dayname[1] =~ /duplex/i) ? 'red' : 
	 $titlecolor; 
     $commentcolor = ($dayname[2] =~ /Feria/i) ? $black : ($dayname[2] =~ /Sabbato/i) ? $blue : $titlecolor;
     $comment = $dayname[2];
     if (open(OUT, ">$outdir/$year/$title.html")) {
       print OUT "<HTML><HEAD><TITLE>$title</HEAD><BODY BGCOLOR=\"#ffffdd\">\n";
       print OUT "<BR><BR><BR><CENTER><TABLE CELLPADDING=20 BGCOLOR=WHITE><TR><TD ALIGN=CENTER>\n";
       print OUT "<FONT COLOR=$daycolor>$dayname[1]<BR></FONT>\n" .
          "$comment<BR><BR>\n" .

    my $item; 
    if ($votive !~ /Defunctorum/i) {foreach $item ('Matutinum', 'Laudes', 'Prima', 'Tertia', 
      'Sexta', 'Nona', 'Vespera', 'Completorium') {
      print OUT "<A HREF=\"$monthday/$item.html\">$item</A>&nbsp;&nbsp;&nbsp;\n";
      if ($item =~ /tertia/i) {print OUT "<BR><BR>\n";}
    }} else {foreach $item ('Matutinum', 'Laudes', 'Vespera') {
      print OUT "<A HREF=\"$monthday/$item.html\">$item</A>&nbsp;&nbsp;&nbsp;\n";
    }}
	print OUT "</TD></TR></TABLE></BODY></HTML>\n";
    close OUT;
   } else {print "$outdir/$year/$monthday/$title.html cannot open\n";}
}

sub generatehora {
  our $command = shift;
  our $date1 = shift;

  $hora = $command;
  precedence($date1); #fills our hashes et variables  
  $daycolor =   ($commune =~ /(C1[0-9])/) ? 'blue' :
    ($dayname[1] =~ /(Quattuor|Feria|Vigilia)/i) ? $black : 
    ($dayname[1] =~ /duplex/i) ? 'red' : 
	$titlecolor; 
  $commentcolor = ($dayname[2] =~ /Feria/i) ? $black : ($dayname[2] =~ /Sabbato/i) ? $blue : $titlecolor;
  $comment = $dayname[2];

  our $psalmnum1 = 0;
  our $psalmnum2 = 0;                           
  our $octavam = ''; #to avoid duplication of commemorations
  our $htmltext = '';
	  
  # prepare title	   

  #prepare main frames
  $title = ($hora =~ /vesper/i) ? "Ad Vesperas" :  "Ad $hora";
  if (substr($title,-1) =~ /a/i) {$title .= 'm';}
  $message = "$month-$day-$year $title";
  $mw->update();
  
  $background = ($whitebground) ? "BGCOLOR=\"white\"" : "BGCOLOR=\"$framecolor\"";

  $headline = setheadline();
  htmlHead($title);
  $htmltext .= "<BODY VLINK=$visitedlink LINK=$link BGCOLOR=\"$framecolor\"> ";
  $htmltext .= 
    "<P ALIGN=CENTER><FONT COLOR=$daycolor>$dayname[1]<BR></FONT>\n" .
    "$comment<BR><BR>\n" .
    "<FONT COLOR=MAROON SIZE=+1><B><I>$title</I></B></FONT>\n" .
    "&nbsp;&nbsp;&nbsp;&nbsp;</P>\n";
  if ($hora =~ /vesper/i) {$hora = 'Vespera';}
  horas($hora); 
  $htmltext .= "</BODY></HTML>";
}  

sub chantmessage {
  $message = ($Hk < 3) ? 'Install mbr folder and point to it in Hhoras.ini for chant' :
    ($voicecolumn =~ /chant/) ?
    "Call 'Options' 'Chant' and set 'Generate chant' button to mute if you do not want chant files" :
    "Call 'Options' 'Chant' and set 'Generate chant' button to chant if you want chant files";
}

