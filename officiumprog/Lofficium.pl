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

our $padx = 5;
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
use Tk::JPEG;
use Tk::Widget;
use Tk::widgets;
use Tk::Checkbutton;
use Tk::Scale;
use Tk::Dialog;
use Tk::Pane;
use Tk::Scrollbar;
use Tk::Radiobutton;
use Tk::Optionmenu;
use Tk::Canvas;
use Tk::Text;
use Tk::ROText;
use Tk::ErrorDialog;
use Tk::Clipboard;
use Tk::Font;
use Tk::Table;
use GD;
use Text::Wrapper;

#use WIN32::OLE;
#use WIN32;
#use Win32::SAPI5;
#use WIN32::Registry;
#use Win32::Process;
#use Win32::Sound;


our $Tk = 1;
our $Hk = 0;
our $Ck = 0;
our $notes = 0;
our $missa = 0;
our $caller = 0; #1=office is called for dirge
our $caller1 = 0; #actual value of $caller for the case calling Lauds from dirge Matins
our $dirge = 0; #1=call from 1st vespers, 2=call from Lauds
our $dirgeline = ''; #dates for dirge from Trxxxxyyyy

our $officium = 'officium.pl';
our $version = 'Divino Afflatu';
our ($browsertime, $date1);
our ($popupwindow, $popupcell, $popupheight, $voicegrey1, $voicegrey2);

our $ScreenSaveActive = undef;
$iexplore = ''; #'iexplore';


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

#*** collect standard items
require "dialogcommon.pl";
require "horascommon.pl";
require "horas.pl";
require "specials.pl";
require "specmatins.pl";
require "Awebdia.pl";
require "Apopup.pl";
require "Asetup.pl";
require "Akalendar.pl";
require "Aedit.pl";
require "Acheck.pl";
#require "Achant.pl";
if (-e "monastic.pl") {require "monastic.pl";}
require "tfertable.pl";
require "Aordo.pl";

#get parameters
getini('Ahoras'); #files, colors

our ($lang1, $lang2, $expand, $column);
our %translate; #translation of the skeleton label for 2nd language 
our $sanctiname = 'Sancti';
our $temporaname = 'Tempora';
our $communename = 'Commune';
our $ordostatus = 0;

our $phoplayer = "$mbrfolder/phoplayer.exe";
$phoplayer =~ s/\//\\/g;

our $mw = MainWindow->new();

#internal script, cookies
our %dialog = %{setupstring("$datafolder/Ahoras.dialog")};
our %setup = %{setupstring("$datafolder/Ahoras.setup")};
eval $setup{general};
eval $setup{'Param'};	      
eval $setup{'Colors'};
if ($Tk > 2) {eval $setup{'Chant'};}
$testmode = ($testmode =~ /season/i) ? $testmode : 'regular';

setmdir($version);

$n = $mw->fpixels("1i"); 
if (abs($n - $fpixels) > 5) {
  foreach $item ($blackcell, $redsmall, $titlelargeframe, $linkfont, $dialogfont) {
	  my $fs = floor(getfontsize($item) * $fpixels / $n);
	  $item = setfontsize($item, $fs);
  }
  $fpixels = floor($n + .5);
  setsetup('Colors', $blackcell,$redsmall,$titlelargeframe,$linkfont,$dialogfont, $voicegrey1, $voicegrey2);
}

fontgener();	

our $command = '';
our $hora = $command; #Matutinum, Laudes, Prima, Tertia, Sexta, Nona, Vespera, Completorium
my $d = gettoday(1);  
if ($browsertime !~ /$d/) {
  $completed = 0;
  $browsertime = $d;
}
our $buildscript = ''; #build script
our $searchvalue = '';
if (!$searchvalue) {$searchvalue = '0';}
our $votive = '';
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
$mw->configure(-title=>'Officium');

$mw->configure(-background=>$framecolor, -height=>$fullheight, -width=>$fullwidth);
$mw->OnDestroy(\&finalsave);

$firstcall = 0;
our @command = splice(@command, @command);
our $laudescont = 0;
if ($ARGV[0] =~ /ordo/) {$ordostatus = 'Ordo';}
mainpage();
$firstcall = 0;
MainLoop();


#*** mainpage();
# creates the opening and horas pages
sub mainpage {  
                
if ($firstcall == 1) {return;}
$firstcall = 1;
$hora = $command;
$mw->configure(-title=>"Divinum Officium $hora");
$error = '';
$voiceposadd = 0;

precedence(); #fills our hashes et variables  
our $logtimestart = time();
our $psalmnum1 = 0;
our $psalmnum2 = 0;                           
our $octavam = ''; #to avoid duplication of commemorations

our $only = ($lang1 =~ /$lang2/ || $lang2 =~ /$lang1/i) ? 1 : 0;
our ($priest, $width, $blackfont, $redfont, $smallblack, $smallfont, $titlefont,
  $black, $red, $blue);
our ($doline, $keyfreq, $dofreq, $basetime,$voweltime, $vowelmod, $mono);
our $pressedkey = 0;
our $actcell = ($version =~ /(1955|1960)/) ? -3 : -1;

our ($voice, $voicecontinue, @voicenames, @voicemaxline, @notelines, @speecharray, $speechind, $voiceposadd);
our $voicelang = ($voicecolumn =~ /\#2/) ? $lang2 : $lang1;
eval $setup{"Voice$voicelang"};	   
our @voicedict;
if (open (INP, "$datafolder/$voicelang/Psalterium/tts.txt")) {
  @voicedict = <INP>;
  close INP
}
if ($voicecolumn =~ /[12]/ && $expand !~ /(all|psalms)/i) {
  $voicecolumn = 'mute';
  $error .= "For $expand mode, voice column shall be and set to mute\n"; 
}
definevoice(); 		 
if ($command !~ /laudes/i) {$anteflag = 0;}
our $voicehold = 0;
		  
# prepare title
$daycolor =   ($commune =~ /(C1[0-9])/) ? $blue :
   ($dayname[1] =~ /(Quattuor|Feria|Vigilia)/i) ? $black : 
   ($dayname[1] =~ /duplex/i) ? $red : 
   $titlecolor; 
$commentcolor = ($dayname[2] =~ /Feria/i) ? $black : ($dayname[2] =~ /Sabbato/i) ? $blue : $titlecolor;
$comment = $dayname[2];

#prepare main frames
$title = ($hora =~ /vesper/i) ? 'Ad Vesperas' : ($hora) ? "Ad $hora" : "Divinum Officium";

if (substr($title,-1) =~ /a/i) {$title .= 'm';}
 
@horas=getdialogcolumn('horas','~',0);
for ($i = 0; $i < 10; $i++) {$hcolor[$i] = $blue;}
if ($date1 eq gettoday() && $hora && $completed < 8 && 
  $hora =~ substr($horas[$completed+1], 0, 4)) {
  $completed++;
}
for ($i = 1; $i <= $completed; $i++) {$hcolor[$i] = $titlecolor;}

$height = floor($fullheight * 4 / 12);
$height2 = floor($height / 2);

if ($mwf) {$mwf->destroy();}
$mw->idletasks();

$mwf = $mw->Scrolled('Pane', -scrollbars=>'osoe',
 -width=>$fullwidth, -height=>$fullheight, -background=>$framecolor)
 ->pack(-side=>'top', -padx=>$padx, -pady=>$pady);
  $headline = setheadline();


#*** topframe
$topframe = $mwf->Frame(-background=>$framecolor)->pack(-side=>'top', -fill=>'x', -ipady=>$pady);
$lb = $topframe->Label(-text=>$headline)
  ->pack(-side=>'top', -padx=>$padx);
configure($lb, $framecolor, $titlefont, $daycolor);
$lb = $topframe->Label(-text=>$comment)
  ->pack(-side=>'top', -padx=>$padx);
configure($lb, $framecolor, $smallblack, $commentcolor);
$tframe = $topframe->Frame(-background=>$framecolor)->pack(-pady=>$pady);
$lb = $tframe->Label(-text=>$title)->pack(-side=>'left', -padx=>$padx);
configure($lb, $framecolor, $titlefont, $titlecolor);  
$tframe->Entry(-textvariable=>\$date1, -width=>10, -background=>$framecolor)
  ->pack(-side=>'left', -padx=>$padx);	   


## here come the prevnext buttons
$but = $tframe->Button(-borderwidth=>0, -image=>$imgptr, -highlightthickness=>0, -relief=>'flat',
  -command=>sub{prevnext(-1)})
  ->pack(-side=>'left', -ipadx=>'3', -ipady=>'3');	 
setimage($but, "down", 12);
configure($but, $framecolor, $titlefont);
$but = $tframe->Button(-borderwidth=>0, -image=>$imgptr, -highlightthickness=>0, -relief=>'flat',
  -command=>sub{mainpage()})
  ->pack(-side=>'left', -ipadx=>'3', -ipady=>'3');	 
setimage($but, "button", 12);
configure($but, $framecolor, $titlefont);
$but = $tframe->Button(-borderwidth=>0, -image=>$imgptr, -highlightthickness=>0, -relief=>'flat',
  -command=>sub{prevnext(1)})
  ->pack(-side=>'left', -ipadx=>'3', -ipady=>'3');	 
setimage($but, "up", 12);
configure($but, $framecolor, $titlefont);

$tframe->Button(-text=>'Kalendarium', -background=>$framecolor, -borderwidth=>0, -foreground=>$blue,
  -command=>sub{kalendar()})
  ->pack(-side=>'left', -padx=>$padx);

#*** middleframe
our $middleframe = $mwf->Frame(-background=>$framecolor, -borderwidth=>$border, -relief=>'flat')
->pack(-side=>'top', -fill=>'x');

if ($ordostatus) {ordo();}
elsif ($command && ($votive !~ /Defunctorum/i || $command !~ /(Prima|Tertia|Sexta|Nona|Completorium)/i)) {
  $middleframe->configure(-highlightthickness=>'0');
  if ($command =~ /vesper/i) {$command = 'Vespera';}
  horas($command);
} else {
  $lb = $middleframe->Label(-text=>'Ordinarium', -background=>$framecolor)
    ->grid(-row=>'0', -column=>'0', -pady=>$pady);
  configure($lb, $framecolor, $titlefont, $titlecolor);
  $lb = $middleframe->Label(-text=>'Psalterium', -background=>$framecolor)
    ->grid(-row=>'0', -column=>'1', -pady=>$pady);
  configure($lb, $framecolor, $titlefont, $titlecolor);
  $lb = $middleframe->Label(-text=>'Proprium de tempore', -background=>$framecolor)
    ->grid(-row=>'0', -column=>'2', -pady=>$pady);
  configure($lb, $framecolor, $titlefont, $titlecolor);
  
  ## here come the images
  $img1 = $middleframe->Label(-borderwidth=>0, -image=>$imgptr)
    ->grid(-row=>1, -column=>0, -rowspan=>2); 
  setimage($img1, "breviarium", $height);
  $img2 = $middleframe->Label(-borderwidth=>0, -image=>$imgptr)
    ->grid(-row=>1, -column=>1); 
  setimage($img2, "psalterium", $height2);
  $img3 = $middleframe->Label(-borderwidth=>0, -image=>$imgptr)
    ->grid(-row=>1, -column=>2); 
  setimage($img3, "tempore", $height2);
  $img4 = $middleframe->Label(-borderwidth=>0, -image=>$imgptr)
    ->grid(-row=>2, -column=>1); 
  setimage($img4, "commune", $height2);
  $img5 = $middleframe->Label(-borderwidth=>0, -image=>$imgptr)
    ->grid(-row=>2, -column=>2); 
  setimage($img5, "sancti", $height2);

  $lb = $middleframe->Label(-textvariable=>\$version, -background=>$framecolor)
    ->grid(-row=>'3', -column=>'0', -pady=>$pady);
  configure($lb, $framecolor, $titlefont, $red);
  $lb = $middleframe->Label(-text=>'Proprium Sanctorum', -background=>$framecolor)
    ->grid(-row=>'3', -column=>'1', -pady=>$pady);
  configure($lb, $framecolor, $titlefont, $titlecolor);
  $lb = $middleframe->Label(-text=>'Commune Sanctorum',  -background=>$framecolor)
    ->grid(-row=>'3', -column=>'2', -pady=>$pady);
  configure($lb, $framecolor, $titlefont, $titlecolor);
}

if (!$ordostatus) {
#*** bottomframe
$bottomframe = $mwf->Frame(-background=>$framecolor)->pack(-side=>'top', -fill=>'x');

$bframe1 = $bottomframe->Frame(-background=>$framecolor)->pack(-side=>'top', -pady=>$pady);

for ($i = 1; $i < 9; $i++) {
  my $item = $horas[$i];
  $but = $bframe1->Button(-text=>$item,  -background=>$framecolor, -borderwidth=>0,
    -command=>sub{$command = $item; mainpage();})
	->pack(-side=>'left', -padx=>$padx);
  configure($but, $framecolor, $titlefont, $hcolor[$i]);

}

$bframe2 = $bottomframe->Frame(-background=>$framecolor)->pack(-side=>'top', -pady=>$pady);

my $c;
($labelfont, $c) = setfont($smallfont);  

my 	@names = ('Expand', 'Version', 'Mode', 'Finish', 'Column2', 'Votive');
for ($i = 0; $i < @names; $i++) {
  $item = $names[$i];  
  if ($item =~ /Finish/i) {
    my $but;
    if ($command) {
      $but = $bframe2->Button(-text=>"$command completed", -background=>$framecolor,
        -borderwidth=>0, -command=>sub{$command=''; mainpage();})
        ->grid(-column=>$i, -row=>0, -padx=>$padx);
    } else {
      $but = $bframe2->Button(-text=>"Finish", -background=>$framecolor,
        -borderwidth=>0, -command=>sub{exit();})
        ->grid(-column=>$i, -row=>0, -padx=>$padx);
      
	}  
    configure($but, $framecolor, $smallfont, $blue); 
  } else {
    $lb = $bframe2->Label(-text=>"$names[$i]", -borderwidth=>0)
       ->grid(-column=>$i, -row=>0, -padx=>$padx);
    configure($lb, $framecolor, $smallfont, $titlecolor); 
  }
}

@optarray1 = ('all', 'psalms', 'nothing', 'skeleton');	 
$bframe2->Optionmenu(-options=>\@optarray1, -textvariable=>\$expand, #-background=>$framecolor, 
   -border=>1, -font=>$labelfont, -command=>sub{mainpage();})
   ->grid(-column=>0, -row=>1, -padx=>$padx);

@versions = ('Trident 1570', 'Trident 1910', 'Divino Afflatu', 'Reduced 1955', 'Rubrics 1960', '1960 Newcalendar');
if (-e "$Bin/monastic.pl") {unshift(@versions, 'pre Trident Monastic');}
$bframe2->Optionmenu(-options=>\@versions,-textvariable=>\$version, #-background=>$framecolor,
   -border=>1, -font=>$labelfont, -command=>sub{mainpage();})
   ->grid(-column=>1, -row=>1, -padx=>$padx);
                      
@optarray3 = ('Regular', 'Seasonal', 'Season', 'Saint', 'Common');
$bframe2->Optionmenu(-options=>\@optarray3,-textvariable=>\$testmode, #-background=>$framecolor,
  -border=>1, -font=>$labelfont, -command=>sub{mainpage();})
  ->grid(-column=>2, -row=>1, -padx=>$padx);

$bframe2->Button(-text=>'Kalendarium', -background=>$framecolor, -borderwidth=>0,  -foreground=>$blue,
  -command=>sub{kalendar()})
  ->grid(-column=>3, -row=>1, -padx=>$padx);

opendir(DIR, $datafolder); 
@a = readdir(DIR);
close DIR;
@optarray4 = splice(@optarray4, @optarray4);
foreach $item (@a) {
  if ($item !~ /\./ && (-d "$datafolder/$item") && $item =~ /^[A-Z]/ && $item !~ /help/i) 
    {push(@optarray4, $item);}
}		
$bframe2->Optionmenu(-options=>\@optarray4,-textvariable=>\$lang2, #-background=>$framecolor,
   -border=>1, -font=>$labelfont, -command=>sub{mainpage();})
   ->grid(-column=>4, -row=>1, -padx=>$padx);

if ($version !~ /monastic/i) {
  @optarray5 = ('proper', 'hodie', 'Dedication', 'Defunctorum', 'Parvum B.M.V.');
  $bframe2->Optionmenu(-options=>\@optarray5,-textvariable=>\$votive, #-background=>$framecolor,
    -border=>1, -font=>$labelfont,
    -command=>sub{mainpage();})
    ->grid(-column=>5, -row=>1, -padx=>$padx);
}

$bframe3 = $bottomframe->Frame(-background=>$framecolor)->pack(-side=>'top', -pady=>$pady);
$edit = ($savesetup < 2) ? 'Show files' : 'Edit';
$bframe3->Button(-text=>$edit, -background=>$framecolor, -borderwidth=>0, -font=>$labelfont,
  -command=>sub{edit()})
   ->pack(-side=>'left', -padx=>$padx);
$bframe3->Button(-text=>'Options', -background=>$framecolor, -borderwidth=>0, -font=>$labelfont,
  -command=>sub{setuptable($setuptab)})
  ->pack(-side=>'left', -padx=>$padx);

$bframe3->Label(-text=>'   ', -background=>$framecolor, -borderwidth=>0, -font=>$labelfont)
  ->pack(-side=>'left', -padx=>$padx);

foreach ('Versions', 'Credits', 'Rubrics', 'Help', 'Controls') {
  my $item = $_;
  my $item1 = ($item =~ /help/i) ? 'Ahelp' : lcfirst($item); 
  $bframe3->Button(-text=>$item, -background=>$framecolor, -borderwidth=>0, -font=>$labelfont, 
    -command=>sub{system("start $browser \"$datafolder/Help/$item1.html\"");}) 
    ->pack(-side=>'left', -padx=>$padx);  
}
  
$bframe3->Label(-text=>'   ', -background=>$framecolor, -borderwidth=>0, -font=>$labelfont)
  ->pack(-side=>'left', -padx=>$padx);

@optarray6 = ('mute');
if ($voice) {@optarray6 = ('mute', 'read col #1', 'read col #2');}

if ($voice && $phoplayer && $Tk > 2 && $lang1 =~ /Latin/i) {push(@optarray6, 'chant col #1');}
$bframe3->Optionmenu(-options=>\@optarray6,-textvariable=>\$voicecolumn, #-background=>$framecolor,
   -border=>1, -font=>$labelfont,
   -command=>sub{mainpage();})
   ->pack(-side=>'left', -padx=>$padx);

$bframe3->Button(-text=>'(Read all hours)', -background=>$framecolor, -borderwidth=>0, -font=>$labelfont,
  -command=>sub{read_all();})
  ->pack(-side=>'left', -padx=>$padx);

$lb = $bottomframe->Label(-textvariable=>\$error, -background=>$framecolor, -foreground=>'red')
    ->pack(-side=>'top', -pady=>$pady);

if ($command) {
  $mw->bind("<Key-Down>"=>sub{$mwf->yview('scroll', "$scrollamount", 'units')}); 
  $mw->bind("<Key-Up>"=>sub{$mwf->yview('scroll', "-$scrollamount", 'units')}); 
  $mw->bind("<Key-Next>"=>sub{$mwf->yview('scroll', "0.5", 'pages')}); 
  $mw->bind("<Key-Prior>"=>sub{$mwf->yview('scroll', "-0.5", 'pages')}); 
  $mw->bind('<MouseWheel>' => \&mouse_scroll);

  $mwf->bind("<Key-F1>"=>sub{$pressedkey = 10;});
  $mwf->bind("<Key-F2>"=>sub{$pressedkey = 20;});
  $mwf->bind("<Key-F3>"=>sub{$pressedkey = 30;});
  $mwf->bind("<Key-F4>"=>sub{$pressedkey = 40;});
  $mwf->bind("<Key-F5>"=>sub{$voicehold=1;});
  $mwf->bind("<Key-F6>"=>sub{$voicehold=0;});
  $mwf->bind("<Key-F7>"=>sub{finish();});
  $mwf->bind("<Key-F8>"=>sub{edit();});
  $mwf->bind("<Key-F9>"=>sub{cell_position(100);});
  $mwf->bind("<Key-0>"=>sub{if ($pressedkey) {cell_position_r($pressedkey-1);}});
  $mwf->bind("<Key-1>"=>sub{cell_position_r($pressedkey - 1 + 1);});
  $mwf->bind("<Key-2>"=>sub{cell_position_r($pressedkey - 1 + 2);});
  $mwf->bind("<Key-3>"=>sub{cell_position_r($pressedkey - 1 + 3);});
  $mwf->bind("<Key-4>"=>sub{cell_position_r($pressedkey - 1 + 4);});
  $mwf->bind("<Key-5>"=>sub{cell_position_r($pressedkey - 1 + 5);});
  $mwf->bind("<Key-6>"=>sub{cell_position_r($pressedkey - 1 + 6);});
  $mwf->bind("<Key-7>"=>sub{cell_position_r($pressedkey - 1 + 7);});
  $mwf->bind("<Key-8>"=>sub{cell_position_r($pressedkey - 1 + 8);});
  $mwf->bind("<Key-9>"=>sub{cell_position_r($pressedkey - 1 + 9);});
  $mwf->bind("<Key-Return>"=>sub{$actcell++;cell_position_r($actcell);});
  $mwf->bind("<Key-H>"=>sub{$voicehold=1;});
  $mwf->bind("<Key-h>"=>sub{$voicehold=1;});
  $mwf->bind("<Key-R>"=>sub{$voicehold=0;});
  $mwf->bind("<Key-r>"=>sub{$voicehold=0;});
  $mw->bind("<Key-I>"=>sub{if ($voice) {$stopvoice = 1; $voice->Speak('  ', 2);}});# $voice->StopSpeaking();}});
  $mw->bind("<Key-i>"=>sub{if ($voice) {$stopvoice = 1; $voice->Speak('  ', 2);}}); # $voice->StopSpeaking();}});
  $mwf->bind("<Key-Insert>"=>sub{$voiceposadd--; $mwf->yview('scroll', -$scrollamount, 'units')});
  $mwf->bind("<Key-Delete>"=>sub{$voiceposadd++; $mwf->yview('scroll', $scrollamount, 'units')});
  $mwf->bind("<Key-Home>"=>sub{$mwf->yview('scroll', -$voiceposadd*$scrollamount, 'units');$voiceposadd=0;});

  $mwf->focus();

  if ($version !~ /(1955|1960)/) {
    $mw->bind("<Key-A>"=>sub{$actcell=-1;cell_position_r($actcell);});
    $mw->bind("<Key-a>"=>sub{$actcell=-1;cell_position_r($actcell);});
    $mw->bind("<Key-E>"=>sub{$actcell=99;cell_position_r($actcell);});
    $mw->bind("<Key-e>"=>sub{$actcell=99;cell_position_r($actcell);});
  }

  if ($building && $buildscript ) {
    $buildframe = $mwf->Frame(-background=>$framecolor)->pack(-side=>'top', -fill=>'x', -ipady=>$pady);
    $width = $fullwidth * 0.8; 
    $buildscript =~ s/[\n]+/\n/g;
    $buildscript =~ s/\n/\<BR\>/g;
    $buildscript =~ s/\_//g;
    $buildscript =~ s/\,\,\,/   /g;

     popupsetcell($buildscript, $lang1, 1, $buildframe, 1);
  }


} else {$mw->focus();} 

$mw->bind("<Key-M>"=>sub{$command='Matutinum'; mainpage();});
$mw->bind("<Key-m>"=>sub{$command='Matutinum'; mainpage();});
$mw->bind("<Key-L>"=>sub{$command='Laudes'; mainpage();});
$mw->bind("<Key-l>"=>sub{$command='Laudes'; mainpage();});
$mw->bind("<Key-P>"=>sub{$command='Prima'; mainpage();});
$mw->bind("<Key-p>"=>sub{$command='Prima'; mainpage();});
$mw->bind("<Key-T>"=>sub{$command='Tertia'; mainpage();});
$mw->bind("<Key-t>"=>sub{$command='Tertia'; mainpage();});
$mw->bind("<Key-S>"=>sub{$command='Sexta'; mainpage();});
$mw->bind("<Key-s>"=>sub{$command='Sexta'; mainpage();});
$mw->bind("<Key-N>"=>sub{$command='Nona'; mainpage();});
$mw->bind("<Key-n>"=>sub{$command='Nona'; mainpage();});
$mw->bind("<Key-V>"=>sub{$command='Vespera'; mainpage();});
$mw->bind("<Key-v>"=>sub{$command='Vespera'; mainpage();});
$mw->bind("<Key-C>"=>sub{$command='Completorium'; mainpage();});
$mw->bind("<Key-c>"=>sub{$command='Completorium'; mainpage();});
$mw->bind("<Key-F>"=>sub{finish();});
$mw->bind("<Key-f>"=>sub{finish();});
$mw->bind("<Key-D>"=>sub{edit();});
$mw->bind("<Key-d>"=>sub{edit();});
$mw->bind("<Key-End>"=>sub{finish();});
}

$mwf->pack(-anchor=>'n');
$mwf->idletasks();
$firstcall = 0;
}  

#*** pressing key F|f = finish
#closes popup or horas page or the program
sub finish {
  if ($voice) {
    if ($voicehold) {$voicehold = 0; $voice->Resume();}
    $stopvoice = 1; $voice->Speak('  ', 2); $voice->StopSpeaking();
  }
                                    
  if ($popupwindow && Exists($popupwindow)) {
    $popupwindow->destroy();
    if ($command) { $mwf->focus();}
  }
  elsif ($command) {@command = ''; $command = ''; mainpage();}
  else {$mw->destroy();}    
}

sub mouse_scroll {
  if ($Tk::event->D > 0) {$mwf->yview('scroll', "-$scrollamount", 'units');}
	else {$mwf->yview('scroll', "$scrollamount", 'units');}
}  
  

sub errorTk {
  my $str = shift; 
  $mw->messageBox(-title=>'Error', -message=>$str, -type=>'OK');
}

#*** Tk::Error($window, $error, $links)
# the implementation of TK error message procedure
# from callbacks
#sub Tk::Error {
# my ($w,$e,@l) = @_;
# $error = $e;
# foreach (@l) {$error .= "\n$_";}
# $mw->messageBox(-title=>'Error', -message=>$error, -type=>'OK');
#}

#*** finalsave()
# called before exit
# saves horas.setup file with the current values
sub finalsave {
  $geometry = $mw->geometry();
  setsetup('general', $expand, $version, $testmode, $local, $lang2, $accented, $voicecolumn, $completed, $browsertime, 
    $geometry, $fpixels, $popupgeo, $setuptab);
  if ($savesetup) {
    savesetuphash('Ahoras', \%setup);
  }      
  if ($ScreenSaveActive) {
    my ($key, $type, $reserved);
    if ($::HKEY_CURRENT_USER->Open("Control Panel\\Desktop", $key)) {
    $key->QueryValueEx("ScreenSaveActive", $type, $ScreenSaveActive);
    if (!$ScreenSaveActive) {$key->SetValueEx("ScreenSaveActive", $reserved, $type, 1);}
  }
 } 
}

sub setimage {
  my ($wdg, $iname, $height) = @_;	 

  my $img1;
  $img = new GD::Image("$datafolder/$iname.gif");
  if (!$img) {print "$datafolder/$iname.gif cannot open\n"; return;}
  my ($w, $h) = $img->getBounds();
  my $width = $height * $w / $h;	 
  $img1 = new GD::Image($width, $height);
  $img1->copyResized($img,0,0,0,0,$width, $height, $w, $h);	 
  
  if (open(OUT,  ">$datafolder/tmp/$iname.jpg")) {     
    binmode OUT;    
    print OUT $img1->jpeg();
    close OUT;
    my $imgphoto = $mw->Photo(-file=>"$datafolder/tmp/$iname.jpg", -format=>'jpeg'); 
	  $wdg->configure(-image=>$imgphoto,-borderwidth=>0);
  } else {print "$datafolder/tmp/$iname.jpg cannot read";}
}

sub configure {
  my ($widget, $bgcolor, $fontline, $color) = @_;	 
  my ($font, $c) = setfont($fontline);
  if (!$color) {$color = $c;}	 
  $widget->configure(-font=>$font, -foreground=>$color, -background=>$bgcolor);
}

sub prevnext {
  my $inc = shift;
  my ($month, $day, $year) = split('-', $date1);

  my $d= date_to_days($day,$month-1,$year);
  
  my @d = days_to_date($d + $inc);
  $month = $d[4]+1;
  $day = $d[3];
  $year = $d[5]+1900;     
  $date1 = "$month-$day-$year";
}

#*** writetimelog()
#writes the elapsed time to tmp/timelog.txt
sub writetimelog { 
  my $elapsed = floor(time() - $logtimestart);
  my $sec = $elapsed % 60;
  my $min = floor ($elapsed / 60); 
  if ($min < 3) {return;}
  if (open(OUT, ">>$datafolder/tmp/timelog.txt")) {
      print OUT "$version $date1 $hora ($duplex) $min:$sec\n";
      close OUT;
  }  else 
    {print "$version $date1 $hora ($testmode=$duplex) $min:$sec min\n"}

}

#*** read_all()
# read all 8 offices for the day
sub read_all {  
  if ($voicecolumn =~ /mute/) {errorTk("Set voicemode to one of the columns first!"); return;}
  @command = ('Prima', 'Tertia', 'Sexta', 'Nona', 'Vespera', 'Completorium'); 
  $command = 'Matutinum';
  mainpage();
  $actcell = -3;
  cell_position($actcell);
}