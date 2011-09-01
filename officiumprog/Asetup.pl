#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 09-25-08
# Setup dialog

#use warnings;
#use strict "refs";
#use strict "subs";

my $a = 4;

sub setuptable {
  my $name = shift;
  if (!$name) {$name = 'Param'}
  if ($popup && Exists($popup)) {$popup->destroy();}
  my $c = $dialogfont;
  $c =~ s/ \#*[0-9a-z]+\s+on\s+\#*[0-9a-z]+\s*$//i;
  $dbfnt = $c;
  $dwfnt = $c;
  $error = '';
                    
  if ($name =~ /Param/i) 
    {setuprut('Param',getsetuppar('Param'),$dialog{'helpparam'},\&setupproc)}
  elsif ($name =~ /Colors/i)
    {setuprut('Colors', getsetuppar('Colors'), $dialog{'helpcolors'}, \&setupproc)}
  elsif ($phoplayer && $Tk > 2 && $name =~ /Chant/i)
    {setuprut('Chant', getsetuppar('Chant'), $dialog{'helpchant'}, \&setupproc)}
  elsif ($name =~ /Voice/i) { 
    eval $setup{"Voice$voicelang"};
	  setuprut("Voice$voicelang", getsetuppar('Voice'), $dialog{'helpvoice'}, \&setupproc)
  } else {$name = 'Param'; mainpage();}

}

sub setupproc {
  fontgener();
  definevoice();
  if ($command) {$mwf->focus();} else {$mw->focus();}
}

#*** helpmessage($helptext)
# Toggles Toggle "Help" "" to "Roll back" $helptext
sub helpmessage {
 my $helptext = shift; 
 if ($helpOK =~ /back/) {$helpstring = ""; $helpOK = 'Help';}
 else {$helpOK = 'Roll back'; $helpstring = $helptext;}
 $mw->update();
 return;
}

#*** addhelp($fr, $popup, $helptext
# adds help button to $fr frame and a new adjacent fram to fr in $popup
# prepares helpmessage callback by saving the text
sub addhelp {
  my ($fr, $popup, $helptext) = @_;
  my $wraplen = floor($fullwidth / 4);
  $fr->Button(-textvariable=>\$helpOK, 
    -borderwidt=>0,-command=>sub{helpmessage($helptext);})->pack(-side=>'top');
  $frh=$popup->Frame()->pack(-side=>'left');
  $frh->Label(-textvariable=>\$helpstring,-justify=>'left', -font=>$dbfnt, -wraplength=>$wraplen)
    ->pack(-expand=>1);
}

#*** setuprut($name, $script, $helptext, \&endproc, $fullsize)
# generates a Toplevel popup dialog using $script and $helptext
# NAME is the title of the dialog, also the name of the .ini file created by the data
#
# SCRIPT is a string scalar contisting on lines separated by ';;' two semicolons
# each line have 3 or 4 elements separated by '~>' sign
# labelstring~>$default~>type~>mode
# labelstring is the name of the label
# $default holds the the default value
# type = Label | Entry~>'width' | Text~>'rows'x'columns' | 
#        Checkbutton  | Radiobutton~>'itemlist' | Optionmenu~>itemarray |
#        Listbox~>'itemlist' | Scale~>'from'~'to'~'step' | Scalentry~>from~to~step |
#        Dirsel | Filesel~>stock |
#        Color | Font | Pixel |Position | Points | Area | Ngon
#    itemlist is a comma separated list e.g "Radiobutton~>add,sub,both"
#    itemarray is either ~>Optionmenu~>\@oarray @oarray defined by the caller program, 
#       or ~>Optionmenu~>oarray and defined by  [oarray] comma separated list entry in .setup file
#       or ~>Optionmenu~>{item1, item2, ...} list
#    stock option results a possibility to select the item from the stocked images
#  script usually is defined in a .setup file, and obtained by getsetuppar($name) sub
#
# HELPTEXT is a string shown as help
#
# if ENDPROC is set, the setup process returns calling the 
#    referenced process
#
# if FULLSIZE nonzero the dialog box starts as scrolled
sub setuprut { 
  my $name = shift;
  if (!$name) {$name = "noname";}
  my $scripto = shift; 
  if (!$scripto) {$message = 'No setup parameter'; return;}
  my $script = $scripto;
  $script =~ s/\n\s*//g;
  my $htext = shift;
  my $endproc = shift; 
  if (!$endproc) {$endproc = "";}
  my $fullsize = shift;    
  if (!$fullsize) {$fullsize = 0;}
  @mouseselref = ('filesel', 'color', 'background', 'pixel', 'position', 'points', 'area', 'ngon');
  @mouserefvar = (\$imageref, \$pixelref, \$pixelref, \$pixelref, \$positionref, \$pointsref,
     \$arearef, \$ngonref); 
  @mouserefcomment =(
     "Click on a stock image to select", "Click on image if any to get pixelcolor",
	 "Click on image if any to get pixelcolor","Click on image if any to get pixelcolor",
	 "Click on image to get x y coordinates", 
	 "Click on image to get one of the series of x y coordinates",
	 "Doubleclick on image for corner, move-drag, doubleclick to finish",
	 "Doubleclick on image for center, move-drag, doubleclick to finish");

  $selectindicator = 100;

  my @frames = splice(@frames, @frames);
  my @script = split(';;', $script);

  $popup = $mwf->Toplevel(-title=>"Options: $name"); 
  if (!$dialogx || $dialogx < 1) {$dialogx = 1;}
  if (!$dialogy || $dialogy < 1) {$dialogy = 1;}
  if ($dialogx > $fullwidth - 100) {$dialogx = $fullwidth - 100;}
  if ($dialogy > $fullheight - 100) {$dialogy = $fullheight - 100;}
  $popup->geometry("+$dialogx+$dialogy");
  $popup->OnDestroy(sub{
    $dialogx = $popup->x();
	  $dialogy = $popup->y();
    $ngonref = $arearef = $positionref = $pointsref = $pixelref = $imageref = '';
    });
  my $padx = 10;
  my $pady = 5;

  if ($fullsize) {
    $popupframe = $popup->Scrolled('Pane',-scrollbars=>'osoe',
      -width=>$fullwidth-100,
	  -height=>$fullsize)->pack();
    $popupframe->Frame;
  }
  else {$popupframe = $popup;}
  $popupframe->configure(-takefocus=>0);
  
  $fr = $popupframe->Frame(-borderwidth=>3,-relief=>'ridge',-takefocus=>0)
      ->pack(-padx =>$padx,-pady=>20,-side=>'left');


  my $i;
  my $labelwidth = 0;
  my @sparam = splice(@sparam, @sparam);

  @parname = splice(@parname, @parname);
  @parvalue = splice(@parvalue, @parvalue);
  @parmode = splice(@parmode, @parmode);
  @parpar = splice(@parpar, @parpar);

  $labellength = 1;

  for ($i = 0; $i < @script; $i++) {
     my @elems = split('~>', $script[$i]); 
     if (length($elems[0]) > $labellength) {$labellength = length($elems[0]);}
     $parname[$i] = $elems[0]; 
     $parvalue[$i] = $elems[1]; 
	 $parmode[$i] = $elems[2];
	 $parpar[$i] = $elems[3];  
  }
  $labellength += 2;

  $frtop = $fr->Frame(-borderwidth=>0, -relief=>'flat', -takefocus=>0)
    ->pack(-side=>'top', -pady=>10);
  $frtop->Button(-text=>'Param',-takefocus=>1, -font=>$dbfnt,
      -command=>sub{savesetup($name, \@parname, \@parmode, \@parvalue, \@parwidget, '');
         setuptable(param);})
	 ->pack(-side=>'left', -padx=>$padx);
  $frtop->Button(-text=>'Colors',-takefocus=>1, -font=>$dbfnt,
      -command=>sub{savesetup($name, \@parname, \@parmode, \@parvalue, \@parwidget, '');
	  setuptable('Colors');})
		  ->pack(-side=>'left', -padx=>$padx);
  if ($phoplayer && $Tk > 2) {$frtop->Button(-text=>'Chant',-takefocus=>1, -font=>$dbfnt,
      -command=>sub{savesetup($name, \@parname, \@parmode, \@parvalue, \@parwidget, '');
	     setuptable('Chant');})
		  ->pack(-side=>'left', -padx=>$padx);}
  $frtop->Button(-text=>'Voice',-takefocus=>1, -font=>$dbfnt,
      -command=>sub{savesetup($name, \@parname, \@parmode, \@parvalue, \@parwidget, '');
	  setuptable('Voice');})
		  ->pack(-side=>'left', -padx=>$padx);
  $frtop = $fr->Label(-text=>"$name", -borderwidth=>0, -relief=>'flat', -takefocus=>0)
    ->pack(-side=>'top', -pady=>10);

  $ngonref = $arearef = $positionref = $pointsref = $pixelref = $imageref = '';
  $ngon = $area = $position = $points = "";
  $areamode = $ngonmode = $mousenomove = 0;
  my $rows = @script;
  my ($width, $rpar, @rpar, $size, @size, $range, @range, $j, $h, $w);
  my $table = $fr->Table(-rows=>$rows,-columns=>2,-scrollbars=>'',-takefocus=>0)
    ->pack(-ipadx=>10, -ipady=>5);
  
  for ($i = 0; $i < @script; $i++) {
     if (!$parmode[$i]) {next;}

	   for ($j = 0; $j < @mouseselref; $j++) {
        if ($j == 1) {next;}
        if ($parmode[$i] =~ /^\s*$mouseselref[$j]/i) {last;}
     } 

	   if ($j < @mouseselref) {
        my $si = $i;
        my $sj = $j;
        $table->Radiobutton(-text=>$parname[$i], variable=>\$selectindicator,
          -command=>sub{selectreference("$si", "$sj", \$parvalue["$si"]);},
          -value=>"$si",-takefocus=>1, -font=>$dbfnt)
	      ->grid(-row=>$i,-column=>0,-pady=>$pady, -sticky=>'w');
     
     } elsif ($parmode[$i] =~ /^button/i) {
        my $buttoni = $i; 
        $table->Button(-text=>$parname[$i],-takefocus=>1,-command=>sub{eval("$parvalue[$buttoni]")},
		  -font=>$dbfnt)
		  ->grid(-row=>$i,-column=>0,-pady=>$pady,-columnspan=>2);
     
     } else {
        $table->Label(-width=>$labellength,-anchor=>'w',-text=>$parname[$i],
          -takefocus=>0, -font=>$dbfnt)
	      ->grid(-row=>$i,-column=>0,-pady=>$pady, -sticky=>'w');
     }

     if ($parmode[$i] =~ /^label/i) {
       $width = $parpar[$i]; 
       if (!$width || $width < 10) {$width = 30;}
       if (length($parvalue[$i]) > 30) {$parvalue[$i] = wrap($parvalue[$i], $width);}
       $parwidget[$i] = $table->Label(-text=>$parvalue[$i],-takefocus=>0,
	     -font=>$dbfnt)
	     ->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>$pady);
     
     } elsif ($parmode[$i] =~ /^entry/i) {
       $width = $parpar[$i];
       if (!$width || $width == 0) {$width = 3;}
       $parwidget[$i] = $table->Entry(-textvariable=>\$parvalue[$i],-width=>$width,
         -takefocus=>1,-font=>$dwfnt)
	     ->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>$pady);

     } elsif ($parmode[$i] =~ /^text/i) {
		my @size = split('x',$parpar[$i]);
		my $ti = $i;  
		if (@size < 2) {@size = (3,12);} 
		my $textwidget = $table->Frame()->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>0);
		$parwidget[$i] = $textwidget->Scrolled('Text', -scrollbars=>'osoe',
		   -width=>$size[1],-height=>$size[0],-takefocus=>1,-wrap=>'none',-font=>$dwfnt)
		   ->pack(-side=>'top');
        $parwidget[$i]->Text;
		$parvalue[$i] =~ s/\s\s(\s*)/\n$1/g;
		$parwidget[$i]->insert('end',$parvalue[$i]);
		my $textwidget1 = $textwidget->Frame()->pack(-side=>'top');
		$textwidget1->Button(-text=>'Load',-command=>sub{textloadrut($parwidget["$ti"])},
		  -borderwidth=>0,-font=>$dbfnt)->pack(-side=>'left',-padx=>10);
		$textwidget1->Button(-text=>'Save',-command=>sub{textsaverut($parwidget["$ti"])},
		  -borderwidth=>0,-font=>$dbfnt)->pack(-side=>'left',-padx=>10);
		$textwidget1->Button(-text=>'Wrap',-command=>sub{textwraprut($parwidget["$ti"])},
		  -borderwidth=>0,-font=>$dbfnt)->pack(-side=>'left',-padx=>10);


     } elsif ($parmode[$i] =~ /checkbutton/i) {
       if (!$parpar[$i]) {
	     $parwidget[$i] = $table->Checkbutton(-variable=>\$parvalue[$i],-takefocus=>1,
		   -font=>$dbfnt)
		   ->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>$pady);
       } else {
	     my $checki = $i; 
		 $parwidget[$i] = $table->Checkbutton(-variable=>\$parvalue[$i],-takefocus=>1,
           -command=>sub{eval("$parvalue[$checki]")}, -font=>$dbfnt)
	 	   ->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>$pady);
       }  

      } elsif ($parmode[$i] =~ /radiobutton/i) { 
	        $rpar = $parpar[$i];
			@rpar = split(',', $rpar);
			$w = maxlength(\@rpar);
			$parwidget[$i] = $table->Frame()
			  ->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>0);
			for ($j = 1; $j <= @rpar; $j++) {
			   $parwidget[$i]->Radiobutton(-text=>$rpar[$j-1],-variable=>\$parvalue[$i],
			     -value=>$j,-width=>$w,-takefocus=>1,-font=>$dbfnt)->pack(-anchor=>'w');
            }
      
      } elsif ($parmode[$i] =~ /listbox/i) {
	        $rpar = $parpar[$i];
			@rpar = split(',', $rpar); 
			$h = @rpar;
			$w = maxlength(\@rpar);
			$parwidget[$i] = $table->Listbox( 
               -height=>$h, width=>$w,-takefocus=>1, -font=>$dbfnt)
               ->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>$pady);
            for ($j = 0; $j < @rpar; $j++) {
              $parwidget[$i]->insert('end', $rpar[$j]);
            }
            $parwidget[$i]->selection('set', $parvalue[$i]-1); 
      
      } elsif ($parmode[$i] =~ /^scale/i) {
	       $range = $parpar[$i];
		   @range = split("~", $range);
		   if (!$range[2]) {$range[2] = 1;}
		   my $scalei = $i;
		   my $scalevalue = $parvalue[$i];
           my $dynflag = ($parmode[$i] =~ /dyn/i) ? 1 : 0;
		   if ($parmode[$i] =~ /entry/i) {
		      my $widget1 = $table->Frame()->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>$pady);
			  $parwidget[$i] = $widget1->Entry(-textvariable=>\$parvalue[$scalei],-width=>3,-font=>$dbfnt)
			     ->pack(-side=>'left');
		      $widget1->Scale(-from=>$range[0],-to=>$range[1],
			    -variable=>\$scalevalue,
				-command=>sub{
                   if ($dynflag && $dynamic && $parvalue[$scalei] != $scalevalue) {
                      $parvalue[$scalei] = $scalevalue;
                   } else { $parvalue[$scalei] = $scalevalue;}

                 },
		        -orient=>'horizontal',-borderwidth=>0,-sliderlength=>20,-label=>"",
                -highlightthickness=>0,-troughcolor=>'white',-resolution=>$range[2],
                -takefocus=>1, showvalue=>'False')
                ->pack(-side=>'left',-padx=>5);
           } else {
		     $parwidget[$i] = $table->Scale(-from=>$range[0],-to=>$range[1],-variable=>\$parvalue[$i],
		       -orient=>'horizontal',-borderwidth=>0,-sliderlength=>20,-label=>"",
               -highlightthickness=>0,-troughcolor=>'white',-resolution=>$range[2],
               -takefocus=>1,-font=>$dbfnt)
               ->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>$pady);
           }
                
     } elsif ($parmode[$i] =~ /dirsel/i) {
	     my $diri = $i;
		 my $widget1 = $table->Frame()->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>0);
		 $widget1->Entry(-textvariable=>\$parvalue[$diri],-width=>32,-font=>$dbfnt)
           ->pack(-side=>'left');
		 $parwidget[$diri] = $widget1->Button(        
		   -background=>'#dddddd',
	       -command=>sub{$parvalue[$diri] = dirsel("$parvalue[$diri]")},-font=>$dbfnt)
           ->pack(-side=>'left');
     
     } elsif ($parmode[$i] =~ /filesel/i) {
         my $filei = $i;
         if ($parpar[$filei] =~ /stack/i) {$parpar[$filei] = "shape:txt";} 
		     my $widget2 = $table->Frame()->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>0);
		     $widget2->Entry(-textvariable=>\$parvalue[$filei],-width=>32,-font=>$dbfnt)
           ->pack(-side=>'left');
		     $parwidget[$filei] = $widget2->Button(-background=>'#dddddd',
	         -command=>sub{$parvalue[$filei] = filesel("$parvalue[$filei]", "$parpar[$filei]")},
		       -font=>$dbfnt)
           ->pack(-side=>'left');
     
     } elsif ($parmode[$i] =~ /color/i) {
		 my $coli = $i;  
		 my $widget3 = $table->Frame()->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>0);
		 $widget3->Entry(-textvariable=>\$parvalue[$coli],-width=>8,-font=>$dwfnt)
           ->pack(-side=>'left');
		 $parwidget[$coli] = $widget3->Button(        
		   -background=>$parvalue[$coli],-font=>$dbfnt,
		   -command=>sub{colorsel($table, $coli)},-takefocus=>1)
           ->pack(-side=>'left');
     
     } elsif ($parmode[$i] =~ /font/i) {
	     my $fi = $i;
		   my ($fontclr, $fontbgr, $ffnt) = getcolors($parvalue[$fi]);   

		   $parwidget[$fi] = $table->Button(-textvariable=>\$parvalue[$fi],
		     -foreground=>"$fontclr", -background=>"$fontbgr",
		     -command=>sub{fontsel($fi)},-takefocus=>1, -font=>$ffnt)
           ->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>$pady);
     
     } elsif ($parmode[$i] =~ /^option/i) {
	     my $a = $parpar[$i]; 
		 if (!$a) {$message = "Missing parameter for Optionmenu"; return "";} 
		 if ($a =~ /\@/ || ref($a) =~ /ARRAY/i) {@optarray = eval($a);}	  
		 elsif ($a =~ /^\s*\{(.+)\}\s*$/) {@optarray = split(',', $1);}
		 else {@optarray = getdialogcolumn($a, '~', 0);}
		 my $bgo = $i;	 
     if ($parmode[$i] !~ /select/i) {
        $parwidget[$i] = $table->Optionmenu(-options=>\@optarray,-textvariable=>\$parvalue[$bgo],
          -takefocus=>1,-font=>$dbfnt)
			    ->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>$pady);
     } else {
        $optorig = $parvalue[$bgo]; 
        $parwidget[$i] = $table->Optionmenu(-options=>\@optarray,-textvariable=>\$parvalue[$bgo],
          -takefocus=>1,-font=>$dbfnt,-command=>sub{
			       if ($parvalue[$bgo] =~ /$optorig/) {return;}
             savesetup($name, \@parname, \@parmode, \@parvalue, \@parwidget, $endproc);})
              ->grid(-row=>$i,-column=>1,-sticky=>'e',-pady=>$pady); 
         }        

	   } 
  }
    
  $helpOK = 'Help';										   
  addhelp($fr, $popupframe, $htext);
  $fr->Button(-text=>'Restore original', -borderwidt=>0,
  -command=>sub{restore_original();})->pack(-side=>'top', -pady=>$pady);
  
  $okbutton = $fr->Button(-text=>'O.K.',-takefocus=>1,
    -command=>sub{savesetup($name, \@parname, \@parmode, \@parvalue, \@parwidget, $endproc);})
    ->pack(-side=>'top', -pady=>$pady);
  $fr->Label(-textvariable=>\$error)->pack(-side=>'top', -pady=>$pady);
  
  $fr->focus();
  $helpstring = $htext;
  $popup->idletasks();
  if (!$fullsize) {
    if ($popupframe->height() > $fullheight-100) {$fullsize = $fullheight - 100;}
    elsif ($popupframe->width() > $fullwidth) {$fullsize = $popupframe->height();}
    if ($fullsize) {
      $popup->destroy();
      setuprut($name, $scripto, $htext, $endproc, $fullsize);
    }      
  }
  $helpstring=""; 
}

#*** setsetuppar($setuppar, \@newpar)
# $setuppar is the script controlling setup command
# @newpar is the array of the input values
# Returns the modified $setuppar,
#   changing the actual parameter values
sub setsetuppar {
  my $setuppar = shift;
  my $par = shift;
  my @par = @$par; 
  my @setuppar = split(";;", $setuppar);
  my ($i, $j);
  $setuppar = "";
  for ($i = 0; $i < @setuppar; $i++) {
    if (!$setuppar[$i] || $setuppar[$i] =~ /^\s*\n*$/) {next;}
	  if (!$par[$i] && $par[$i] ne '0') {$par[$i] = '';}
    my @line = split('=', $setuppar[$i]);
	  $setuppar .= "$line[0]=\'$par[$i]\';;";
  }
  return $setuppar;
}

#*** savesetup($name)
# saves $Bin/$name.ini file, one line for each subsequent parameter pair
# in parname=parvalue format
sub savesetup {
  my $name = shift;
  my $parname = shift; 
  my @parname = @$parname;
  my $parmode = shift;
  my @parmode = @$parmode;
  my $parvalue = shift;
  my @parvalue = @$parvalue;
  my $parwidget = shift;
  @parwidget = @$parwidget;
  my $endproc = shift; 
  
  my $i;
  for ($i = 0; $i < @parname; $i++) {
    if ($parwidget[$i] && Exists($parwidget[$i])) {
	   
	   if ($parmode[$i] =~ /(text)/i) {
	     $parvalue[$i] = $parwidget[$i]->get('1.0', 'end');
         $parvalue[$i] =~ s/\s+\n/\n/g;
         $parvalue[$i] =~ s/\n\n*/\n/g;
         $parvalue[$i] =~ s/\n/  /g;
       
	   } elsif ($parmode[$i] =~ /listbox/i) {
          $parvalue[$i] = $parwidget[$i]->curselection()+1;
       
	   } elsif ($parmode[$i] =~ /Checkbutton/i) {
		  if (!$parvalue[$i]) {$parvalue[$i] = '0';}
       
       } elsif ($parmode[$i] =~ /Label/i) {
          $parvalue[$i] =~ s/\n//g;
       }
    }
  }
  
  setsetup($name, @parvalue);
  eval($setup{$name});



  if ($name) {
    if ($name =~ /voice/i) {$setuptab = 'Voice';}
    else {$setuptab = $name;}
  }
  if ($endproc) { 
   if (Exists($popup)) {$popup->destroy();}
	 $mw->update(); 
     my $i;
	 &$endproc;
	 return;
  }
}

#maxlength(\@a)
# calculates the longest string in the referenced string=array
sub maxlength {
  my $a = shift;
  my @a = @$a;
  my $w = 0;
  foreach (@a) {if ($w > length($_)) {$w = length($_);}}
  return $w;
}

#dirsel($dir)
# calls getOpenFile with $dir as initialdir
# returns the folder of the selected file
sub dirsel {
  my $dir = shift;
  my $dir1 = "$dir/";
  $dir1 =~ s/\//\\/g; 
  my $f = $popup->getOpenFile(-initialdir=>$dir1);
  if (!$f) {return $dir;}
  my ($n, $dn, $a) = fileparse($f); 
  $dn =~ s/\/$//;
  return $dn; 
}

#*** filesel($file, $par)
# calls getOpenfile with initialfile = file, initialdir = folder of file
# and filetypes parameter constructed from $par
# the format of $par 'name:type1,type2,...'
# returns the selected file  
sub filesel {
  my $file = shift;
  my $par = shift; 
 
  my ($file1, $dir1, $a) = fileparse($file); 
  $dir1 = "$dir1/";
  $dir1 =~ s/\//\\/g; 
  my (@par1, @types, $f);
  if ($par) {
     my @par = split(':', $par);
     $par[0] = "$par[0] files";
     $par[1] = "*.$par[1]"; 
     if ($file1 =~ /\.([a-z]+)$/i) {
       my $ext = $1; 
       if ($par[1] !~ /$ext/) {$par[1] .= ",$ext";}
     }
     $par[1] =~ s/\,/\;\*\./g;  
     $types[0] = \@par;
     $types[1] = ["All files", "*.*"];
     $f = $popup->getOpenFile(-initialdir=>$dir1, -initialfile=>$file1,-filetypes=>\@types);
  } else {$f = $popup->getOpenFile(-initialdir=>$dir1, -initialfile=>$file1);}
  if (!$f) {return $file;}
  return $f; 
}

#*** getfiletypearray($name, $files, $path);
# returns the filetype array for getOpenFile or getSaveFile functions
# form $name and $files = 'type1,type2,...' string
# extended by the all files entry
sub getfiletypearray {
  my ($name, $files, $path) = @_;
  my $str = "";
  my @t = split(',', $files);
  foreach (@t) {$str .= "*.$_;"}; 
  if ($path && $path =~ /\.([a-z]+)$/i) {
     my $ext = $1;
     if ($str !~ /$ext/i) {$str .= "*.$ext;";}
  }
  $str =~ s/\;$//;
  my @types = ([$name, $str], ["all files", ".*"]);
  return @types;
}

#*** textloadrut($widget)
# allows to select a .command type file from $Bin/command folder
# and loads the content to $widget Text widget
# this is called by text type dialog widget load tab
sub textloadrut {
  my $widget = shift;
  my $dir = "$Bin/commands";
  $dir =~ s/\//\\/g;
  if (!$commandfile) {$commandfile = "$Bin/commands/command.command";}
  my @types = getfiletypearray("COMMAND files", 'command');
  my $f = $popup->getOpenFile(-initialdir=>"$dir", -initialfile=>basename($commandfile),
    -filetypes=>\@types);
  if (!$f) {return;}
  if (open (INP,"$f")) {
     my @command = <INP>;
	 close INP;
     $commandfile = $f;
     $widget->delete('1.0', 'end');
     foreach (@command) {$widget->insert('end',$_);}
     $widget->update();
  }
}

#*** textsaverut($widget)
# allows to select a .command type file from $Bin/command folder
# and saves the content to $widget Text widget to that file
# this is called by text type dialog widget save tab
sub textsaverut {
  my $widget = shift;
  my $dir = "$Bin/commands";
  $dir =~ s/\//\\/g;
  if (!$commandfile) {$commandfile = "$Bin/commands/command.command";}
  my @types = getfiletypearray("COMMAND files", 'command');
  my $f = $popup->getSaveFile(-initialdir=>$dir, -initialfile=>basename($commandfile),
    -filetypes=>\@types);
  if (!$f) {return;} 
  if ($f !~ /\.command$/i) {$f .= ".command";}
  if (open (OUT,">$f")) {
     $str = $widget->get('1.0', 'end');
     print OUT $str;
	 close OUT;
	 $commandfile = $f;
  }
}

#*** textwraprut($widget)
#wraps unwraps the content of the text widget
sub textwraprut {
  my $widget = shift;
  if ($widget->cget(-wrap) =~ 'none') {$widget->configure(-wrap=>'word');}
  else {$widget->configure(-wrap=>'none');}
}     

#*** checkcolor($color, $dcolor) 
# chacks if the named of described as #rrggbb color is accepted
# by the system, returns the original if yes, $decolor otherwise
# prevets errors using wrong or empty names
sub checkcolor {
  my $ic = shift;
  my $dcolor = shift;
  if (!$ic) {$ic = $dcolor;}
  if (@ic < 3) {$ic=$dcolor}
  return $ic;
}

sub oppositecolor {
  my $ic = shift; 
  if (!$ic) {$ic = 'white';}
  if ($ic < 4) {$ic[0] = $ic[1] = $ic[2] = 0;}
  $ic[0] = 255 - $ic[0];
  $ic[1] = 255 - $ic[1];
  $ic[2] = 255 - $ic[2];
  my $b = sprintf("#%.2x%.2x%.2x", $ic[0], $ic[1], $ic[2]);
  return $b;
}

sub nocleancolor {
  my $ic = shift;
  if (!$ic) {$ic = 'white';}
  if ($ic < 4) {$ic[0] = $ic[1] = $ic[2] = 0;}
  if ($ic[0] == 255) {$ic[0] = 254;}
  if ($ic[0] = 0) {$ic[0] = 1;}
  if ($ic[1] == 255) {$ic[1] = 254;}
  if ($ic[1] = 0) {$ic[1] = 1;}
  if ($ic[2] == 255) {$ic[2] = 254;}
  if ($ic[2] = 0) {$ic[2] = 1;}
  my $b = sprintf("#%.2x%.2x%.2x", $ic[0], $ic[1], $ic[2]);
  return $b;
}

#colorsel($table, $i)
# calls chooseColor dialog with initialcolor in $parvalue[$i]
# saves back the result to $parvalue[$i]
# and sets the background color of $parwidget[$i]
sub colorsel {
  my $table = shift;
  my $i = shift;
  my $c =  $table->chooseColor(-initialcolor=>$parvalue[$i],-title => "Choose color");
  if ($c) {
    $parvalue[$i] = $c;
    $parwidget[$i]->configure(-background=>$c);
  }
  if (!$parvalue[$i] || $parvalue[$i] =~ /^\s+^/) {$parvalue[$i] = 'white';}
}

#fontcolorsel($table, $flag, $widget)
# calls chooseColor dialog with initialcolor of the background ($flag==0) 
# or foreground of $widget
# saves back the result as background or foreground of the widget
# this is called by fontdialog
sub fontcolorsel {
  my ($table, $flag, $widget) = @_;
  my $iclr = ($flag) ? $widget->cget('-foreground') : $widget->cget('-background');
  my $title = ($flag) ? 'foreground' : 'background';
  my $c =  $table->chooseColor(-initialcolor=>$iclr,-title => "Choose $title fontcolor");
  if ($c) {             
    if ($flag) {$widget->configure(-foreground=>"$c"); $clr = $c;}
	  else {$widget->configure(-background=>"$c"); $bgr = $c;}
  }
}

#getcolors($textfont)
# returns foreground background colors and the previous font description
# from a "fontdescription foregroundcolor on backgroundcolor" string
sub getcolors {
  my $textfont = shift;  
  if ($textfont =~ /\s+(\#*[0-9a-z]+\s+on\s+\#*[0-9a-z]+)\s*$/i) { 
	 my $f = $`;
	 my @a = split(' on ', $1);   
	 
	 return ($a[0],$a[1], $f);
  } else {return ('black','gray', $textfont);}
}

#*** fontsel($textfont)
# this is called by /font/ type widget
sub fontsel {
  my $i = shift;
  my $f = fontdialog($i);
}    


#*** fontdialog($fi)
#creates a popup dialog to select a font for $parvalue[$fi]
# fontfami, font size, bold and italic options may be selected
# the name of the selected font is listed during the process in proper size
sub fontdialog {
  my $fi = shift;
  $fmode = 0;
  if ($parmode[$fi] =~ /([0-9])/) {$fmode = $1;}	 
  my $fonta = $parvalue[$fi]; 
  if (!$fonta || $fonta !~ /\{.*?\}/) {$fonta = "{Verdana} 12";}
  my $fonttype = $fonta;
  $fonttype =~ s/^\{(.*?)\}.*$/$1/i;
  $fontsize = $fonta;
  $fontsize =~ s/^.+?\}\s+([0-9]+).*$/$1/i;
  my $fontweight = ($fonta =~ /bold/i) ? 1 : 0;
  my $fontslant = ($fonta =~ /italic/i) ? 1 : 0;
  our ($clr, $bgr, $font) = getcolors($fonta);
  if ($fmode & 2) {$fontsize = $basesize; $font = setfontsize($font, $basesize);}
  if ($fmode && 1 && $fmode < 5) {$bgr = $bgcolor;}

  my $popup = $fr->Toplevel(-title=>"Select $parname[$fi]");
  $fr0 = $popup->Frame()->pack(-side=>'top');
  $fontlabel = $fr0->Entry(-font=>$font,-textvariable=>\$font,-background=>$bgr,
    -foreground=>$clr, -state=>'disabled')
    ->pack();
  my $fr1 = $popup->Frame()->pack(-side=>'top',-ipadx=>30);

  my $fr11 = $fr1->Frame()->pack(-side=>'left',-ipadx=>10);
  $fr11->Label(-text=>'type')->pack(-side=>'top'); 
  my @fontfamilies = splice(@fontfamilies, @fontfamilies);
  if (!@fontfamilies) {@fontfamilies = $popup->fontFamilies();}  
  @fontfamilies = sort(@fontfamilies);

  unshift(@fontfamilies, 'System');
  unshift(@fontfamilies, 'Helvetica');
  unshift(@fontfamilies, 'Times');
  unshift(@fontfamilies, $fonttype);

  $fonttype1 = $fonttype;
  $fr11->Optionmenu(-options=>[@fontfamilies],
    -command=>sub {
    $fonttype = $fonttype1;
	my $fb = ($fontweight) ? 'bold' : '';
	my $fs = ($fontslant) ? 'italic' : ''; 
	$font = "{$fonttype} $fontsize $fb $fs ";
	$fontlabel->configure(-font=>$font);},
	-variable=>\$fonttype1)->pack(-side=>'top');   
  if ($fmode != 3) {
    my $fr12 = $fr1->Frame()->pack(-side=>'left', -ipadx=>10);
    my $state = ($fmode & 2) ? 'disabled' : 'normal';
    my $entry = $fr12->Scale(-from=>6,-to=>18,-variable=>\$fontsize,
	  -orient=>'horizontal',-borderwidth=>0,-sliderlength=>20,-label=>"",
      -highlightthickness=>0,-troughcolor=>'white',-resolution=>1,
      -takefocus=>1,-font=>$dbfnt, -state=>$state,
	  -command=>sub {
	    my $fb = ($fontweight) ? 'bold' : '';
	    my $fs = ($fontslant) ? 'italic' : ''; 
	    $font = "{$fonttype} $fontsize $fb $fs ";
	    $fontlabel->configure(-font=>$font);})
	  ->pack(-side=>'top',-ipady=>5);
  }

  my $fr13 = $fr1->Frame()->pack(-side=>'left', -ipadx=>10);
  $fr13->Label(-text=>'bold')->pack(-side=>'top');
  $fr13->Checkbutton(-variable=>\$fontweight,
    -command=>sub {my $fb = ($fontweight) ? 'bold' : '';
	my $fs = ($fontslant) ? 'italic' : ''; 
	$font = "{$fonttype} $fontsize $fb $fs ";
	$fontlabel->configure(-font=>$font);})
	  ->pack(-side=>'top');


  my $fr14 = $fr1->Frame()->pack(-side=>'left', -ipadx=>10);
  $fr14->Label(-text=>'italic')->pack(-side=>'top');
  $fr14->Checkbutton(-variable=>\$fontslant,
    -command=>sub{my $fb = ($fontweight) ? 'bold' : '';
	my $fs = ($fontslant) ? 'italic' : ''; 
	$font = "{$fonttype} $fontsize $fb $fs ";
	$fontlabel->configure(-font=>$font);})
	  ->pack(-side=>'top');

  if ($fmode < 5) {
    $fr2 = $popup->Frame()->pack(-side=>'top',-pady=>5);
    my $but = $fr2->Entry(-textvariable=>\$clr)->pack(-side=>'left');
    $but->bind("<Key-Tab>"=>sub{$fontlabel->configure(-foreground=>$clr);}); 

    $fr2->Button(-text=>'foreground', -borderwidth=>0, -foreground=>$blue,
      -command=>sub{fontcolorsel($popup, 1, $fontlabel)})
      ->pack(-side=>'left');
    $fr2->Label(-text=>' ')->pack(-side=>'left',-padx=>10);
    if (($fmode & 1) == 0) {
      my $but = $fr2->Entry(-textvariable=>\$bgr)->pack(-side=>'left');
      $but->bind("<Key-Tab>"=>sub{$fontlabel->configure(-background=>$bgr);}); 
      $fr2->Button(-text=>'background', -borderwidth=>0, -foreground=>$blue,
        -command=>sub{fontcolorsel($popup, 0, $fontlabel)})
        ->pack(-side=>'left', -padx=>10);
    }
  }
  
  $fr3 = $popup->Frame()->pack(-side=>'top',-pady=>5);
  $fr3->Button(-text=>'O.K.',-width=>20,
    -command=>sub{
	$font =~ s/^\s*//;
	$font =~ s/\s*$//;
	my $fontclr = $fontlabel->cget('-foreground');
	my $fontbgr = $fontlabel->cget('-background');   
	$parwidget[$fi]->configure(-foreground=>$fontclr,-background=>$fontbgr);
	$parvalue[$fi] = "$font $clr on $bgr"; 
	$popup->destroy();
    $popup = '';})
    ->pack();
  $popup->focus();
}

#*** getfles($dir)
# returns the sorted arra of files 
# corresponding to $imagetypes setup variable 
# in $dir folder
sub getfles {
  my $dir = shift;
  my @fles = splice(@fles, @fles);
  if (opendir (DIR, $dir)) {
    while ($fles = readdir(DIR)) {
	  if ($fles =~ /\.jpg/i) {
	    $fles =~ s/\.jpg//;
    	push (@fles, $fles);
	  }
    }
    closedir (DIR);   
    @fles = sort(@fles);
  }
  return @fles;
}

#*** max2($d1, $d2)
# retuns the greater of $d1, $d2
sub max2 {
  my ($d1, $d2) = @_; 
  if ($d1 < $d2) {return $d2;}
  return $d1;
}

#*** min2($d1, $d2)
# retuns the lesser of $d1, $d2
sub min2 {
  my ($d1, $d2) = @_;
  if ($d1 > $d2) {return $d2;}
  return $d1;
}


#*** printhas(\%hash, $sep)
#returns the referenced hash as key=value$sep string
sub printhash {
  my $hash = shift;
  my %hash = %$hash;
  my $str = "";
  foreach (sort keys %hash) {$str .= "$_=\"$hash{$_}\",";}
  return $str;
}

#*** wrap($str, $lim)
# break $str to have no longer lines than $lim
# returns the modified $str
sub wrap {
  my $str = shift;
  my $lim = shift;
  my @str = split(/([\s\,\;])/, $str);
  my $count = 0;
  $str = '';
  foreach (@str) {
	if ($count + length($_) > $lim) {$str .= "\n"; $count = 0;}
	$str .= $_;
	$count += length($_);
  }
  return $str;
}

sub getindex {
  my ($a, $v) = @_;
  my @a = @$a;
  my $i = 0;
  while ($i < @a) {
    if ($a[$i] =~ /^$v$/) {return $i;}
    $i++;
  }
  return 0;
}

#*** fontgener()
# sets the internally used font descriptions
sub fontgener {
  my $c;
  
  ($titlecolor, $framecolor, $titlefont) = getcolors($titlelargeframe);
  $largesize = getfontsize($titlefont); 

  ($black, $bgcolor, $blackfont) = getcolors($blackcell);
  $basesize = getfontsize($blackfont);

  ($red, $c, $smallfont) = getcolors($redsmall);
  $smallsize = getfontsize($smallfont);

  ($blue, $c, $bluefont) = getcolors($linkfont);
  $bluefont = setfontsize($bluefont, $basesize);
  $linkfont = "$bluefont $blue on $bgcolor";  
  
  $smallblack = setfontsize($blackfont, $smallsize);

  $blackfont = fontgenerrut($blackfont, $black);   
  $italicfont = $blackfont; $italicfont =~ s/$black/italic $black/;
  $smallfont = fontgenerrut($smallblack, $red);
  $redsmall = "$smallfont on $bgcolor";	 
  $smallblack = fontgenerrut($smallblack, $titlecolor);
  $redfont = fontgenerrut($titlefont, $red , 'italic');
  $initiale = setfontsize($titlefont, $largesize+1);
  if ($initiale =~ /\{.*?\} [0-9]+/) {$initiale = $&;}
  $initiale = fontgenerrut($initiale, $red, 'bold italic');
  $largefont = fontgenerrut($titlefont, $red, 'italic');
  $titlefont = fontgenerrut($titlefont, $titlecolor);
}

#*** fontgenerrut($font, $fontcolor, $fontattribute)
# returns the font description
sub fontgenerrut {
  my ($font, $fontcolor, $fontattribute) = @_;
  if ($fontattribute && $font !~ /$fontattribute/i) {$font = "$font $fontattribute";}
  $font = "$font $fontcolor";
  $font =~ s/\s+/ /g;      
  return $font;
}

#*** setfontsize($fullname, $new_size
#changes size parameter in fullname
sub setfontsize {
  my $fullname = shift;
  my $newsize = shift;
  $fullname =~ s/(\{.*?\}) [0-9]+/$1 $newsize/;
  return $fullname;
}

#*** getfontsize($fontname) 
#  returns the size
sub getfontsize {
  my $fontname = shift;
  if ($fontname =~ /\{.*?\} ([0-9]+)/) {return $1;}
  return 10;
}

#*** restore_original() 
# restores the original setup status
sub restore_original {
  my @a;
  if (open(INP, "$datafolder/Ahoras_orig.setup") && open(OUT,  ">$datafolder/Ahoras.setup")) {
    my @a = <INP>;
    close INP;
    foreach $line (@a) {print OUT $line;}
    close OUT;
    %setup = %{setupstring("$datafolder/Ahoras.setup")};
    eval $setup{general};
    eval $setup{'Param'};	      
    eval $setup{'Colors'};
    eval $setup{"Voice$voicelang"};
    if ($popup && Exists($popup)) {$popup->destroy();}
    mainpage();
 }
 else {error("FATAL ERROR Ahoras_orig.setup is missing");}
}   
    