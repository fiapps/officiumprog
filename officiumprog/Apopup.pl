#!/usr/bin/perl

#αινσφυϊόϋΑΙ
# Name : Laszlo Kiss
# Date : 09-25-08
# Divine Office popup

package horas;
#1;

$a = 4;

sub popup {
  my $popup = shift;
  my $lang = shift;

  $speecharray[0] = '';					   	 
  my $savedexpand = $expand;
  $expand = 'all';
  if ($popup =~ /\&/) {$popup =~ s /\s/\_/g;}
  $label = $popup;
  $label =~ s/[\$\&]//;
  $text = resolve_refs($popup, $lang1);  
 
  $width = floor($fullwidth / 2);
  $height = floor(7 * $fullheight / 8);  
  $x = floor($fullwidth / 2);
  $y = floor($fullheight / 16);
  if ($popupgeo && $popupgeo =~ /([0-9]+)x([0-9]+)/) {
   if ($1 < $width / 2 || $2 < $height / 2 || $1 > 2*$width || $2 > $height) {$popupgeo = '';}
  }
  if (!$popupgeo) {$popupgeo = $width . "x$height+$x+$y";}
  if ($popupgeo =~ /([0-9]+)x([0-9]+)\+/i) {$width = $1; $height = $2; $popupheight = $height - 100;}

  if ($popupwindow && Exists($popupwindow)) {$popupwindow->destroy();}
  $popupwindow = $mw->Toplevel(-background=>$framecolor, -title=>$popup);
  $popupwindow->geometry($popupgeo);
  $popupframe = $popupwindow->Scrolled('Pane', -scrollbars=>'osoe', -background=>$framecolor,
    -width=>$width, -height=>$height)
    ->pack(-side=>'top');
  $popupwindow->OnDestroy(\&popupdestroy);
  my ($font, $color) = setfont($blackfont);  

  my $lb = $popupframe->Label(-text=>$label, -background=>$framecolor)
    ->pack(-side=>'top', -pady=>20, -fill=>'both');
   configure($lb, $framecolor, $largefont, $titlecolor);

  my $cellframe = $popupframe->Frame(-background=>$framecolor)->pack(-side=>'top');

  $blackfontsize = 11;
  if ($font =~ /\{.*?\}\s*([0-9]+)/) {$blackfontsize = $1;}   

  popupsetcell($text, $lang1, 1, $cellframe, $only);
  if (!$only) {
    $text = resolve_refs($popup, $lang2);    
    popupsetcell($text, $lang2, 2, $cellframe, $only);
  }
 

  my $but;
  $expand = $savedexpand;
  $but = $popupframe->Button(-text=>'Finish', -background=>$framecolor,
    -borderwidth=>0, -command=>sub{$popupwindow->destroy();})
    ->pack(-side=>'top', -pady=>10);
  configure($but, $framecolor, $smallblack, $titlecolor);

  $popupwindow->focus();
  $popupwindow->bind("<Key-Down>"=>sub{$popupframe->yview(scroll, "$scrollamount", 'units')}); 
  $popupwindow->bind("<Key-Up>"=>sub{$popupframe->yview(scroll, "-$scrollamount", 'units')}); 
  $popupwindow->bind("<Key-Next>"=>sub{$popupframe->yview('scroll', "0.5", 'pages')}); 
  $popupwindow->bind("<Key-Prior>"=>sub{$popupframe->yview('scroll', "-0.5", 'pages')}); 
  $popupwindow->bind('<MouseWheel>' => \&popup_scroll);
  $popupwindow->bind("<Key-F>"=>sub{finish();});
  $popupwindow->bind("<Key-f>"=>sub{finish();});
  $popupwindow->bind("<Key-End>"=>sub{finish();});
}

sub popup_scroll {
  if ($Tk::event->D > 0) {$popupframe->yview(scroll, "-$scrollamount", 'units');}
	else {$popupframe->yview(scroll, "$scrollamount", 'units');}
}  

sub popupdestroy {
  $popupgeo=$popupwindow->geometry();
  if ($command) {$mwf->focus();}
  else {$mw->focus();}
}


sub popupsetcell {
  my $text = shift;	    
  my $lang = shift;   
  $column = shift;
  my $popupframe = shift;
  my $only = shift;  

 if ($lang =~ /Latin/i) {$text = jtoi($text);}

                        
  $wrapper = Text::Wrapper->new();

  my $linewidth = ($only) ? floor($width * .8 / $blackfontsize) + 4 : 
    floor($width * .4 / $blackfontsize)  + 2;  
  my $height = 5;   
  
  our @popupcell;		          
  $popupcell[$column] = $popupframe->ROText(-background=>$bgcolor, -width=>$linewidth, 
    -height=>$height, -highlightthickness=>$border, -relief=>'flat', -wrap=>'none', 
	-highlightcolor=>$titlecolor) 
	->grid(-row=>0, -column=>$column-1, -sticky=>'ns');
  configure($popupcell[$column], $bgcolor, $blackfont);

  $text =~ s/\n/ /g;
  $text =~ s/  / /g;
  $text =~ s/\<BR\>/\n/g;

  my ($ind1, $ind2);
  my $addheight = 0;
  my @text = split("\n", $text);
  for ($speechind = 0; $speechind < @text; $speechind++) { 
    $speechindex1 = $popupcell[$column]->index(insert);
    $text = "lll$speechind $text[$speechind]";  
    my $after = $text;

    while ($after =~ /\{\^(.*?)\,\,(.*?)\^\}/g) {
	  my $before = $`;
	  my $attr = $1;
	  my $str = $2;
	  $after = $';	
	  if ($before) {setcell_rut($popupcell[$column], $before, $linewidth,0);}
	  my @attr = split(',', $attr);			  
      $fontsize = $blackfontsize;
	  if ($attr[0] =~ /\{.*?\}\s*([0-9]+)/) {$fontsize = $1;}
	  $tagnum++;
      $popupcell[$column]->tagConfigure("tag$tagnum", -font=>"$attr[0]", -foreground=>"$attr[1]");
	  $ind1 = $popupcell[$column]->index(insert);
	  my $newlinewidth = floor($linewidth * $blackfontsize / $fontsize);
	  setcell_rut($popupcell[$column], $str, $newlinewidth,0); 

	  $ind2 = $popupcell[$column]->index(insert);	
	  my @ind1 = split('\.', $ind1);
	  my @ind2 = split('\.', $ind2);
	  if ($fontsize > $blackfontsize + .5) { 
	    $addheight += ($fontsize / $blackfontsize - 1); 
	  }	 
	  $popupcell[$column]->tagAdd("tag$tagnum", $ind1, $ind2);
    }								  
    setcell_rut($popupcell[$column], $after, $linewidth,0);
    $speechindex2 = $popupcell[$column]->index(insert);
    $popupcell[$column]->tagAdd("spoken$speechind", $speechindex1, $speechindex2);  
    setcell_rut($popupcell[$column], "\n", $linewidth,0);
  }

  $ind1 = $popupcell[$column]->index(insert);	  
  $addheight = ceil($addheight);
  if ($ind1 =~ /\./) {$height = $` + $addheight;}	  
  $popupcell[$column]->configure(-height=>$height);
  $popupcell[$column]->tagConfigure("all", -lmargin1=>10, -lmargin2=>10);
  $popupcell[$column]->tagAdd("all", '1.0', 'end');
 } 

 
