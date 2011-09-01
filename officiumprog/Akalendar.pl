#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 09-25-08
# Divine Office Kalendarium

package horas;
#1;

#use warnings;
#use strict "refs";
$a = 4;

sub kalendar { 
  $hora = '';
  my $saveonly = $only;
  $only = 0;

  $kmonth = $month; 
  $kyear = $year;
  @origyear = split('-', gettoday()); 

  $smallgray = $smallblack;
  $boldblue = addattribute($bluefont, 'bold', $blue);
  $boldblack = addattribute($blackfont, 'bold', $black);
  $boldred = addattribute($blackfont, 'bold', $red);
  $italicblue = addattribute($linkfont, 'italic', $blue);
  $italicblack = addattribute($blackfont, 'italic', $black);
  $italicred = addattribute($blackfont, 'italic', $red);

  kalendarrut($kmonth, $kyear);

  $mw->bind("<Key-Down>"=>sub{$mwf->yview(scroll, "$scrollamount", 'units')}); 
  $mw->bind("<Key-Up>"=>sub{$mwf->yview(scroll, "-$scrollamount", 'units')}); 
  $mw->bind("<Key-Next>"=>sub{$mwf->yview('scroll', "0.5", 'pages')}); 
  $mw->bind("<Key-Prior>"=>sub{$mwf->yview('scroll', "-0.5", 'pages')}); 
  $mw->bind('<MouseWheel>' => \&mouse_scroll);
  $only = $saveonly;
}

sub kalendarrut {
  my $kmonth = shift;
  my $kyear = shift;  

@monthnames = ('Januarius', 'Februarius', 'Martius', 'Aprilis', 'Majus', 'Junius',
  'Julius', 'Augustus', 'September', 'October', 'November', 'December');
@monthlength = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
@daynames = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fry', 'Sat');

$title = "Kalendar: $monthnames[$kmonth-1] $kyear";
                                  
if ($mwf) {$mwf->destroy();}
$mw->idletasks();

$mwf = $mw->Scrolled('Pane', -scrollbars=>'osoe',
 -width=>$fullwidth, -height=>$fullheight, -background=>$framecolor)
 ->pack(-side=>'top', -padx=>$padx, -pady=>$pady);

#*** topframe
$topframe = $mwf->Frame(-background=>$framecolor)->pack(-side=>'top', -pady=>$pady);
$top1 = $topframe->Frame(-background=>$framecolor)->pack(-side=>'top');
my $i;
for ($i = $kyear - 9; $i <= $kyear; $i++) {setkky($top1, $i);}
$top1->Button(-text=>'hodie', -background=>$framecolor, -borderwidth=>0, -foreground=>$blue,
  -command=>sub{$date1 = gettoday(); mainpage();})
  ->pack(-side=>'left', -padx=>$padx);
for ($i = $kyear + 1; $i < $kyear + 10; $i++) {setkky($top1, $i);}

$top2 = $topframe->Frame(-background=>$framecolor)->pack(-side=>'top');
$lb = $top2->Label(-text=>$title, -background=>$framecolor)->pack(-side=>'left', -padx=>$padx);
configure($lb, $framecolor, $titlefont, $titlecolor);

$top3 = $topframe->Frame(-background=>$framecolor)->pack(-side=>'top');
for ($i = 1; $i < 13; $i++) {setkkm($top3, $i);}


$bottomframe = $mwf->Frame(-background=>$framecolor)->pack(-side=>'top', -pady=>$pady);

$bottomframe->Optionmenu(-options=>\@versions,-textvariable=>\$version, #-background=>$framecolor,
   -border=>1, -command=>sub{kalendarrut($kmonth, $kyear);})
   ->pack(-side=>'left', -padx=>$padx);

$middleframe = $mwf->Frame(-background=>$framecolor, -borderwidth=>1, -relief=>'solid')
  ->pack(-side=>'top', -pady=>$pady);

table_start();

$to = $monthlength[$kmonth - 1];   
if ($kmonth == 2 && leapyear($kyear)) {$to++;}  
for ($cday = 1; $cday <= $to; $cday++) {
  $date1 = sprintf("%02i-%02i-%04i", $kmonth, $cday, $kyear);
  $d1 = sprintf("%02i",  $cday);
  $winner = $commemoratio = $scriptura = '';
  %winner = %commemoratio = %scriptura = {};

  precedence($date1); #for the daily item      
  @c1 = split(';;', $winner{Rank});  
  @c2 = (exists($commemoratio{Rank})) ? split(';;', $commemoratio{Rank}) :
    (exists($scriptura{Rank}) && ($c1[3]!~ /ex C[0-9]+[a-z]*/i ||
    ($version =~ /trident/i && $c1[2] !~ /(ex|vide) C[0-9]/i))) ? 
     split(';;', "Scriptura: $scriptura{Rank}") : 
    (exists($scriptura{Rank})) ? split(';;', "Tempora: $scriptura{Rank}") : ();
  
  $c1 = $c2 = ''; 
  if (@c1) {
	  my @cf = split('~', setheadline($c1[0], $c1[2]));
    $c1 =  ($c1[3] =~ /(C1[0-9])/) ? setfont($boldblue, $cf[0]) :
        (($c1[2] > 4 || ($c1[0] =~ /Dominica/i)) && $c1[1] !~ /feria/i)
		? setfont($boldred, $cf[0]) : setfont($boldblack, $cf[0]); 
      $c1 = "$c1" . setfont($smallgray, "  $cf[1]");
  } 
  
  if (@c2) {
	  my @cf = split('~', setheadline($c2[0], $c2[2]));
    $c2 = ($c2[3] =~ /(C1[0-9])/) ? setfont($italicblue, $cf[0]) :
      ($c2[2] > 4) ? setfont($italicred, $cf[0]) : setfont($italicblack, $cf[0]); 
    $c2 = "$c2" . setfont ($smallgray, "  $cf[1]");
  } 

  if ($winner =~ /sancti/i) {($c2, $c1) = ($c1, $c2);}
  $c1 =~ s/Hebdomadam/Hebd/i;
  $c1 =~ s/Quadragesima/Quadr/i;
  $c1 =~ s/\s*$//;
  $c2 =~ s/\s*$//;

  if ($dirge) { $c1 .= setfont($smallblack, ' dirge');}

  if (!$c2 && $dayname[2]) {$c2 = setfont($smallblack, $dayname[2]);}
  if ($version !~ /1960/ && $winner{Rule} =~ /\;mtv/i) {$c2 .= setfont($smallblack, ' m.t.v.');}

  $column = 1;  
  setcell($c1);
  $column = 2;
  setcell($c2);
  my $cd = sprintf("%02i", $cday);
  my $cdt = "$daynames[$dayofweek] $cd";
  $cell[$searchind - 1][2] = $middleframe->Button(-text=>$cdt, -background=>$framecolor,
    -borderwidth=>$border, -foreground=>$blue,
  	-command=>sub{$date1 = "$kmonth-$cd-$kyear", mainpage();}) 
  	->grid(-row=>$searchind-1, -column=>2, -sticky=>'nsew', -ipadx=>$padx);
}
  table_end();


$bottomframe = $mwf->Frame(-background=>$framecolor)->pack(-side=>'top', -pady=>$pady);

$bottomframe->Optionmenu(-options=>\@versions,-textvariable=>\$version, #-background=>$framecolor,
   -border=>1, -command=>sub{kalendarrut($kmonth, $kyear);})
   ->pack(-side=>'left', -padx=>$padx);

}

sub setkky {
  my $widg = shift;
  my $year = shift;

  my $y = sprintf("%02i", $year);
  $widg->Button(-text=>$y, -background=>$framecolor, -borderwidth=>0, -foreground=>$titlecolor,
    -command=>sub{$kyear = $year; kalendarrut($kmonth, $kyear);})
    ->pack(-side=>'left', -padx=>$padx);
}

sub setkkm {
  my $widg = shift;
  my $month = shift;   

  my $m = substr($monthnames[$month-1], 0, 3);
  $widg->Button(-text=>$m, -background=>$framecolor, -borderwidth=>0, -foreground=>$titlecolor,
    -command=>sub{$kmonth = $month; kalendarrut($kmonth, $kyear);})
    ->pack(-side=>'left', -padx=>$padx);
}

sub addattribute {
  my ($font, $attrib, $color) = @_;
  my ($fonttype, $fontsize) = ($font =~ /(\{.*?\})\s+([0-9]+)/) ? ($1, $2) : ('{Times}', 12);
  return "$fonttype $fontsize $attrib $color";
}


