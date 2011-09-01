#!/usr/bin/perl

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 09-25-2008
# Show/edit files

package horas;
#1;

#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FATAL=>qw(all);
$a = 4;

sub edit {

$edit1 = 0;
$skeleton = 0;
$pind1 = 0;
$pind2 = 0;
$coupled = 0;
$compare = 0;
$wrapper = Text::Wrapper->new();
$filechanged = 0;
$expand1 = 0;
$searchtext = '';
$search = '';
$searchnum = 0;
$searchline = '';
$searchlang = '';
$searchfolder = '';
$searchprefix = '';

$elang1 = $lang1;  #the first column
$folder1 = ($winner =~ /tempora/i) ? 'Tempora' : 'Sancti';
if ($winner =~ /(TemporaM|SanctiM)/) {$folder1 .= 'M';}
$prefix1 = '';
$filename1 = ($folder1 =~ /Tempora/i) ? "$dayname[0]-$dayofweek" : 
  ($folder1 =~ /sancti/i) ? get_sday_e($month, $day, $year) : '';	 
if ($folder1 =~ /Tempora/i && $dayofweek > 0 && $monthday) {$filename1 = $monthday;}
                                  
$elang2 = 'none';  #the second column
$folder2 = ($winner =~ /tempora/i) ? 'Tempora' : 'Sancti';
if ($winner =~ /(TemporaM|SanctiM)/) {$folder2 .= 'M';}
$prefix2 = '';
$filename2 = ($folder2 =~ /Tempora/i) ? "$dayname[0]-$dayofweek" : 
  ($folder2 =~ /sancti/i) ? get_sday_e($month, $day, $year) : '';
if ($folder2 =~ /Tempora/i && $dayofweek > 0 && $monthday) {$filename2 = $monthday;}

@folders1=('Ordinarium','Psalterium','Tempora','Sancti','Commune','psalms','psalms1','tones',
  'TemporaM','SanctiM','CommuneM','Tabulae','Martyrologium','Martyrologium1','Martyrologium2','program','test');
@folders2=('Ordinarium','Psalterium','Tempora','Sancti','Commune','psalms','psalms1',
  'Martyrologium','TemporaM','SanctiM','CommuneM','test');

@languages1 = split(',',$dialog{languages});
@languages2 = split(',',$dialog{languages});
unshift(@languages2, 'search');
unshift(@languages2, 'none');

if ($editwindow && Exists($editwindow)) {$editwindow->destroy();}
$edittop = '';
$editframe = '';

#my $butimage1 = new GD::Image("$datafolder/button.gif");
#my ($w, $h) = $butimage->getBounds();
#my $width = $height * $w / $h;	 
#$butimage = new GD::Image($width, $height);
#$butimage->copyResized($butimage,0,0,0,0,$width, $height, $w, $h);	 




$editwindow = $mw->Toplevel(-background=>$framecolor, -title=>'Edit');
$editwindow->geometry($fullwidth . "x$fullheight+0+0");

$editwindow->OnDestroy(\&edit_destroy);
editrut()
}

sub editrut {
  if ($filechanged)  {savedialog();}
  $editfilename = "$datafolder/$elang1/$folder1/$filename1.txt";
  $editfilename =~ s/Latin\/tones/tones/i;
  $masschange = 0;
  $error = '';

  if ($editframe) {$editframe->destroy(); $editframe = '';}
  if ($edittop) {$edittop->destroy(); $edittop = '';}
  $mw->idletasks();

  if ($folder1 =~ /program/) {$edit1 = 0; $coupled = 0; $compare = 0;}
  if ($edit1) {$skeleton = 0;}
  if ($folder1 =~ /program/i) {$lang2 = 'none';}
  

  #*** collect files for column1
  ($files1, $filename1, $prefix1) = getfolders($elang1, $folder1, $prefix1, $filename1);
  @files1 = @{$files1};  			
  if ($coupled && $elang1 !~ /$elang2/) {$folder2 = $folder1; $filename2 = $filename1; $prefix2 = $prefix1;}

  #*** collect files for column2
  if ($elang2 !~ /(none|search)/i) {
    ($files2, $filename2, $prefix2) = getfolders($elang2, $folder2, $prefix2, $filename2);
    @files2 = @{$files2};
  
  } else {@files2 = splice(@files2, @files2); $filename2 = '';}


  $edittop = $editwindow->Frame(-background=>$framecolor)
    ->pack(-side=>'top', -ipady=>$pady);
  $edittop1 = $edittop->Frame(-background=>$framecolor)
    ->pack(-side=>'top', -pady=>$pady);
  $top1frame = $edittop1->Frame(-borderwidth=>1, -relief=>'solid', -background=>$framecolor)
    ->pack(-side=>'left', -padx=>$padx, -ipadx=>$padx, -ipady=>$pady);
  $i = 0;
  foreach ('language', 'folder', 'prefix', 'filename') {setlabel($top1frame, $_, 0, $i); $i++;}
  $top1frame->Optionmenu(-options=>\@languages1, -textvariable=>\$elang1, #-background=>$framecolor,
    -border=>1, -font=>$labelfont, -command=>sub{editrut();})
      ->grid(-row=>'1', -column=>'0', -padx=>$padx, -sticky=>'e');
  $top1frame->Optionmenu(-options=>\@folders1, -textvariable=>\$folder1, #-background=>$framecolor,
    -border=>1, -font=>$labelfont, -command=>sub{editrut();})
      ->grid(-row=>'1', -column=>'1', -padx=>$padx, -sticky=>'e');
  $entry1 = $top1frame->Entry(-textvariable=>\$prefix1, -width=>5, -background=>$framecolor)
      ->grid(-row=>'1', -column=>'2', -padx=>$padx, -sticky=>'e');
  $entry1->bind("<Key-Tab>"=>sub{editrut();}); 
  
  $top1frame->Optionmenu(-options=>\@files1, -textvariable=>\$filename1, #-background=>$framecolor,
    -border=>1, -font=>$labelfont, -command=>sub{editrut();})
      ->grid(-row=>'1', -column=>'3', -padx=>$padx, -sticky=>'e');
			   
  $top2frame = $edittop1->Frame(-borderwidth=>1, -relief=>'solid', -background=>$framecolor)
    ->pack(-side=>'left', -padx=>$padx, -ipadx=>$padx, -ipady=>$pady);
  $i = 0;
  if ($elang2 !~ /search/i) {
    foreach ('language', 'folder', 'prefix', 'filename') {setlabel($top2frame, $_, 0, $i); $i++;}
  } else {
    foreach ('language', 'key', 'search for') {setlabel($top2frame, $_, 0, $i); $i++;}
  }
  $top2frame->Optionmenu(-options=>\@languages2, -textvariable=>\$elang2, #-background=>$framecolor,
    -border=>1, -font=>$labelfont, -command=>sub{editrut();})
      ->grid(-row=>'1', -column=>'0', -padx=>$padx, -sticky=>'e');
  if ($elang2 !~ /search/i) {
    $top2frame->Optionmenu(-options=>\@folders2, -textvariable=>\$folder2, #-background=>$framecolor,
      -border=>1, -font=>$labelfont, -command=>sub{editrut();})
        ->grid(-row=>'1', -column=>'1', -padx=>$padx, -sticky=>'e');
    $entry2 = $top2frame->Entry(-textvariable=>\$prefix2, -width=>5, -background=>$framecolor) 
        ->grid(-row=>'1', -column=>'2', -padx=>$padx, -sticky=>'e');
    $entry2->bind("<Key-Tab>"=>sub{editrut();}); 
    $top2frame->Optionmenu(-options=>\@files2, -textvariable=>\$filename2, #-background=>$framecolor,
        -border=>1, -font=>$labelfont, -command=>sub{editrut();})
        ->grid(-row=>'1', -column=>'3', -padx=>$padx, -sticky=>'e');
  } else {
    $entry3 = $top2frame->Entry(-textvariable=>\$key, -width=>5, -background=>$framecolor) 
        ->grid(-row=>'1', -column=>'1', -padx=>$padx, -sticky=>'e'); 
    $entry3 = $top2frame->Entry(-textvariable=>\$search, -width=>20, -background=>$framecolor) 
        ->grid(-row=>'1', -column=>'2', -padx=>$padx, -sticky=>'e'); 
  }

  $top3frame = $edittop->Frame(-background=>$framecolor)
    ->pack(-side=>'top');
  my $checkbox = setcheckbox($top3frame, 'Skeleton', \$skeleton);
  $checkbox->configure(-command=>sub{$expand1 = 0; editrut();});
  setcheckbox($top3frame, 'Coupled', \$coupled);
  setcheckbox($top3frame, 'Compare', \$compare);
  setcheckbox($top3frame, 'Edit', \$edit1);
  if ($savesetup < 2) {setbutton($top3frame, 'Finish', \&closerut, 1);}
  else {
    my $switchflag = ($elang2 !~ /(none|search)/i) ? 1 : 0;
	$savebutton = setbutton($top3frame, 'Save', \&saverut, $edit1);
	saveset();
	setbutton($top3frame, 'Finish', \&closerut, 1);
	setbutton($top3frame, 'Switch', \&switchrut, $switchflag);
	setbutton($top3frame, 'Adjust', \&adjustrut, $edit1);
	setbutton($top3frame, 'Mass change', \&masschangerut, $edit1);
  }
  if ($elang2 =~ /search/i) {
	setbutton($top3frame, 'Search', \&searchrut, 1);
	my $flag = ($search) ? 1 : 0;
	setbutton($top3frame, 'Next', \&nextrut, $flag);
  }

  $top4frame = $edittop->Frame(-background=>$framecolor)
    ->pack(-side=>'top');
   $checklab = $top4frame->Label(-text=>$error)->pack(-side=>'top', -pady=>$pady);
   configure($checklab, $framecolor, $redfont);


 $editheight = floor($mw->height * .8);	 
 $editframe = $editwindow->Frame(-background=>$framecolor, -width=>$fullwidth, -height=>$editheight)
   ->pack(-side=>'top');


#*** load files to show/edit
$title = ($savesetup > 1 && $folder1 !~ /program/i) ? 'Edit' :'Show';
$title .= " files";
@txlat = splice(@txlat, @txlat);
@txvern = splice(@txvern, @txvern);

  my $fname = ($folder1 =~ /program/i) ?  "$Bin/$filename1.pl" :
	 ($folder1 =~ /tones/i) ? "$datafolder/tones/$filename1.txt" :
   "$datafolder/$elang1/$folder1/$filename1.txt";
  if (open(INP, $fname)) {
    @txlat = <INP>;
    close INP;
  } else {$error .= "$fname cannot open";}

if ($elang2 !~ /(none|search)/i) {
  if (open(INP, "$datafolder/$elang2/$folder2/$filename2.txt")) {
    @txvern = <INP>;
    close INP;
  } else {$error .= "$datafolder/$elang2/$folder2/$filename2.txt cannot open";}
}

($cell1, $cellwidth) = seteditcell(0,0);
if ($elang2 !~ /none/i)	{($cell2, $c) = seteditcell(0,1);}
$txlat = $txvern = '';


#*** regular printout
if (!$skeleton) {

  foreach $item (@txlat) {
    $txlat .= $item;
  }							  
  foreach $item (@txvern) {
    $txvern .= "$item";
  }
  $pind1 = $pind2 = 1;

  editcellout($cell1, $txlat, $cellwidth);
  if ($edit1) {$cell1->bind("<Key>", sub{$filechanged = 1; saveset(); return 1;});}
  $cell1->tagConfigure("all", -lmargin1=>10, -lmargin2=>10, -rmargin=>10);
  $cell1->tagAdd("all", '1.0', 'end');

  if ($searchtext) {$search = putaccents($search);} 
  if ($elang2 =~ /search/i) { 
    $txvern = ($searchtext) ? $searchtext :
	  "Enter search string and optional [key], press Search tab";
  } else {$searchtext = ''; $searchnum = 0; $serchline = '';}
  if ($txvern) {
    editcellout($cell2, $txvern, $cellwidth);
    $cell2->tagConfigure("all", -lmargin1=>10, -lmargin2=>10, -rmargin=>10);
    $cell2->tagAdd("all", '1.0', 'end');
  }
  if ($searchtext && $search) {
    findrut($cell1, $search);
    if ($elang2 =~ /search/i && $searchline) {findrut($cell2, $searchline);}
  }

} 

#*** skeleton printout
elsif ($folder1 !~ /program/i) {
  $pind1 = 1;
  $ind1 = $ind2 = 0;
  while ($ind1 < @txlat || $ind2 < @txvern) {
    ($text1, $ind1) = getunit(\@txlat, $ind1);
    ($text2, $ind2) = getunit(\@txvern, $ind2); 
    if ($compare) {    
	  $text1 =~ s/\n[0-9: ]+/\n/;
	  $text1 =~ s/\n[0-9: ]+/ /g;
      $text2=~ s/\n[0-9: ]+/\n/;
      $text2=~ s/\n[0-9: ]+/ /g;
	  $text1 =~ s/ +/ /g;
	  $text2 =~ s/ +/ /g;
    }

	my $rnum = $pind1;

    @text1 = split("\n", $text1);
    @text2 = split("\n", $text2);
    
	
	editcellout($cell1, "\n", $cellwidth);
    my $ind = $cell1->index('insert');

    $cell1->tagConfigure("ref$rnum", -font=>"{Arial} 8", -foreground=>$blue);
    $cell1->insert('insert', '  ');
	  $cell1->insert('insert', "[+]", "ref$rnum");
    $cell1->insert('insert', '  ');
    mouseover($cell1, "ref$rnum");
	$cell1->tagBind("ref$rnum", '<ButtonRelease>'=>sub{
    if ($rnum == $expand1) {$expand1 = 0;}
    else {$expand1 = $rnum;}
    editrut();});
    
	my $t = "$text1[0] "; 
    if ($compare) {
	  $t .= lcompare($text1, $text2);
	  editcellout($cell1, "$t\n", $cellwidth);
      if ($pind1 == $expand1) {for ($ii = 1; $ii < @text1; $ii++)     
        {editcellout($cell1, tcompare($text1[$ii], $text2[$ii]) . "\n", $cellwidth);}}

	} else {
       editcellout($cell1, "$t\n", $cellwidth);
	   if ($pind1 == $expand1) {
	     for ($ii = 1; $ii < @text1; $ii++) {editcellout($cell1, "$text1[$ii]\n", $cellwidth);}
	   }
    }  
	if ($text2) {
        editcellout($cell2, "\n", $cellwidth);
        my $t = $text2[0];
        
        if ($compare) {
	      $t .= lcompare($text2, $text1);
	      editcellout($cell2, "$t\n", $cellwidth);
          if ($pind1 == $expand1) {for ($ii = 1; $ii < @text1; $ii++)     
            {editcellout($cell2, tcompare($text2[$ii], $text1[$ii]) . "\n", $cellwidth);}}

	    } else {
           editcellout($cell2, "$t\n", $cellwidth);
	       if ($pind1 == $expand1) {
		     for ($ii = 1; $ii < @text1; $ii++) {editcellout($cell2, "$text2[$ii]\n", $cellwidth);}
		   }	 
       }  
		
    }


    $pind1++;
  }
} 

#*** program skeleton
else {
  $pind1 = 1;
  $ind1 = 0;
  while ($ind1 < @txlat) {
    ($text1, $ind1) = getunit1(\@txlat, $ind1);
  	my $rnum = $pind1;
    @text1 = split("\n", $text1);
    editcellout($cell1, "\n", $cellwidth);
    my $ind = $cell1->index('insert');

    $cell1->tagConfigure("ref$rnum", -font=>"{Arial} 8", -foreground=>$blue);
    $cell1->insert('insert', '  ');
	  $cell1->insert('insert', "[+]", "ref$rnum");
    $cell1->insert('insert', '  ');
    mouseover($cell1, "ref$rnum");
	  $cell1->tagBind("ref$rnum", '<ButtonRelease>'=>sub{
          if ($rnum == $expand1) {$expand1 = 0;}
      else {$expand1 = $rnum;}
      editrut();});
    editcellout($cell1, "$text1[0]\n", $cellwidth);
    if ($pind1 == $expand1) {for ($ii = 1; $ii < @text1; $ii++) 
      {editcellout($cell1, "$text1[$ii]\n", $cellwidth);}}
    $pind1++;
  }
}
 
 $editwindow->focus();

 #if ($error) {
   my $lab = $edittop->Label(-text=>$error)->pack(-side=>'top', -pady=>$pady);
   configure($lab, $framecolor, $redfont);
 #}

}

sub masschangerut {
  $masschange = 1;
  adjustrut();
}

sub adjustrut {
  if ($filechanged) {saverut();}
  my $t = $cell1->get('1.0', 'end');  
  my @t = adjust($t, $folder1, $elang1);
  $filechanged = 1;
  saveset();
  my $line;
  $t = '';
  foreach $line (@t) {
    #$line = chompd($line);
    $t .= "$line";
  }						  
  $cell1->delete('1.0', 'end');
  $cell1->insert('1.0', $t); 
  $cell1->tagConfigure("all", -lmargin1=>10, -lmargin2=>10, -rmargin=>10);
  $cell1->tagAdd("all", '1.0', 'end');
}

#*** adjust($text, $folder, $lang) adjust raw files sub
sub adjust {
  my $t = shift;       
  my @t = splice(@t, @t);
  @t = split("\n", $t);
  my $i;
  for ($i = 0; $i < @t; $i++) {$t[$i] .= "\n"; }
  my $folder = shift;
  my $lang = shift;    	
  
  if ($lang =~ /magyar/i && $folder =~ /(ordinarium|psalterium|psalms)/i  & $masschange) 
    {return accents($t);}
                          
  #contract hyphenation
  my $j = 0;
  my @o = splice(@o, @o);
  for ($i = 0; $i < @t; $i++) {
    $t[$i] =~ s/~//;
    if ($t[$i] =~ /\-\s*$/) {$o[$j] .= "$`";}
    else {$o[$j] .= $t[$i]; $j++;}
  }
  if ($folder =~ /martyr/i && $lang =~ /english/i) {  
    $j = 0;
    @t = splice(@t, @t);
    for ($i = 0; $i < @o; $i++) {   
      $o[$i] =~ s/â€”//g;
      if ($o[$i] !~ /\.\]*\s*$/) {$t[$j] .= chompd($o[$i]) . ' ';}
      else {
        $t[$j] .= $o[$i];  
        $t[$j] =~ s/  / /g;
        $j++;
      } 
    }
    return (@t);
  } elsif ($folder =~ /martyr/i) {return @o;}
  		 
  #mark with ~ to be contracted
  my $mode = '';                
  for ($i = 0; $i < @o; $i++) {
    my $flag = 0;

    #hash keys
  	if ($o[$i] =~ /\[([a-z 0-9]+?)\]/i) {  
	    $block = $1;    
      if ($block =~ /(Capitulum|Ant\s+[1-4]|Ant\s+(Prima|Tertia|Sexta|Nona)|Lectio|Responsory|Oratio|Versum)/i) {$mode = $1;}
	    else {$mode = '';}  
      $flag = 1;   
	  }
    
  
    #Ant [a-z] skipped
    
    
    if ($block =~ /Ant\s*[a-z]+/i && $block !~ /Ant\s+(Prima|Tertia|Sexta|Nona)/) { 
	    if ($i > 0) {$o[$i - 1] =~ s/~//;}
      next;
    }

	  #special markers
	  if ($o[$i] =~ /^\s*[\!]Hymnus/i) {$mode = ''; $flag = 1;}
      if ($o[$i] =~ /^\s*[RrV]\./) {$mode = 'Versum'; $flag = 2;}
	    if ($mode =~ /versum/i && $o[$i] =~ /^\s*\*/) {$flag = 2;}

	  if ($o[$i] =~ /^\s*[\$\&\@]/) {$mode = ''; $flag = 1;}
	  if ($o[$i] =~ /^\s*[!_]/) {  
	    $flag = 1;
	  }
    if ($o[$i] =~ /^\s*([0-9]+ |v\.)/ && $mode =~ /lectio/i) {$flag = 2;}
 
    #empty or short line
 	  if (!$o[$i] || $o[$i] =~ /^\s*$/ || length($o[$i]) < 4) {$flag = 1;}


    if ($flag) {    
	    if ($i > 0) {$o[$i - 1] =~ s/~//;}
	    if ($flag == 1) {next;}
	  }
    if (!$mode) {next;} 
						
	
  #set tilde
	$o[$i] =~ s/\s*$//;
    $o[$i] .= "~\n";
    next;
  }
	
  #make long lines
  @t = splice(@t, @t);  
  $o[0] =~ s/^\s*//;
  $j = 0;
  for ($i = 0; $i < @o; $i++) {
    if (!$t[$j] || $t[$j] =~ /~\n/) {
      $t[$j] =~ s/[~\n]//;
      $t[$j] =~ s/\s*$//;
      if ($j == 0) {$t[$j] = $o[$i];} else {$t[$j] .= " $o[$i]";}
    } else {
      $j++;
      $t[$j] = $o[$i]; 
    }
  }

  if ($masschange && $folder !~ /Martyr/i) { 
    for ($i = 0; $i < @t; $i++) {   
      if ($lang =~ /latin/i) {
        if ($t[$i] !~ /(vide|ex)\s+C[0-9][a-z]/) {        
          $t[$i] =~ s/([a-z])\-([a-z])/$1$2/ig;
          $t[$i] =~ s/([a-z ])6([a-z])/$1o$2/ig;
          $t[$i] =~ s/([a-z])1([a-z])/$1l$2/ig;
          $t[$i] =~ s/([a-z])\)*3([a-z])/$io$2/ig;
          $t[$i] =~ s/([a-z])[0-9]([a-z])/$1$2/ig;
        }
        $t[$i] =~ s/([a-z])\^([a-z])/$1e$2/ig;
        $t[$i] =~ s/([a-z])H([a-z])/$1li$2/g;
        $t[$i] =~ s/([a-z])iii([a-z])/$1iu$2/ig;
        $t[$i] =~ s/([a-oq-z])ii([a-z][a-z])/$1u$2/ig;
      
      } elsif ($lang =~ /english/i) {
        $t[$i] =~ s/â€”//g; 
        $t[$i] =~ s/\"//g;
        $t[$i] =~ s/\[(.*?[\,\.\?\;]+.*?)\]/\($1\)/g;   #[...] to (...)
        $t[$i] =~ s/\s([\;\,\.\?\!])/$1/g;
      
      } elsif ($lang =~ /magyar/i) { @t = accents(\@t);} #áéíóöõúüûÁÉ
   }
  } 

  $checkerr = "";
  if ($folder =~ /(Commune|Sancti|Tempora|test)/i) {
    $checkerr = check(\@t);
    if (!$checkerr) {$checkerr = "$filename1 no error"};
    $checklab->configure(-text=>$checkerr);
    $mw->update();
  }	 
                                    
  #wrap
  @o = splice(@o, @o);
  $limit = 10000;
  $break = "~\n";
  $mode = '';
  $t[-1] =~ s/\~//;

  foreach $str (@t) {  
  	if ($str =~ /\[([a-z 0-9]+?)\]/i) {     
	    $block = $1;              
      if ($block =~ /(Capitulum|Ant\s*[1-4]|Ant\s+(Prima|Tertia|Sexta|Nona)|Lectio|Responsory|Oratio|Versum)/i) 
        {$mode = $1;}
	    else {$mode = '';}
    }

    if (!$mode) {
      push (@o, $str); 
      next;
    }    
    if (length($str) < $limit) {push (@o, $str); next;}
    my @str = split(/([\s\,\;])/, $str);  
    my $count = 0;
    $str = '';
    foreach (@str) {
	    if ($count + length($_) > $limit && length($_) > 1) {
        push (@o, "$str$break");     
        $count = 0;
        $str = ''
       }
	     $str .= $_;
	     $count += length($_);
    }
    push (@o, $str);
  }
  for ($i = 0; $i < @o; $i++) {
    $o[$i] =~ s/  / /g;
    $o[$i] =~ s/ ~/~/;
    $o[$i] =~ s/ \n/\n/;
  }	 
  return @o;
}

sub accents {
  my $t = shift;
  my @t = @$t;
  for ($i=0; $i < @t; $i++) {
    $t[$i] =~ s/a'/á/g;
    $t[$i] =~ s/e'/é/g;
    $t[$i] =~ s/i'/í/g;
    $t[$i] =~ s/o'/ó/g;
    $t[$i] =~ s/o:/ö/g;
    $t[$i] =~ s/o"/õ/g;
    $t[$i] =~ s/u'/ú/g;
    $t[$i] =~ s/u:/ü/g;
    $t[$i] =~ s/u"/û/g;
    $t[$i] =~ s/A'/Á/g;
    $t[$i] =~ s/E'/É/g;
    $t[$i] =~ s/O'/Ó/g;
    $t[$i] =~ s/O:/Ö/g;   
    $t[$i] =~ s/O"/Ô/g;   
    $t[$i] =~ s/U'/Ú/g;
    $t[$i] =~ s/U:/Ü/g;
    $t[$i] =~ s/U"/Û/g;

    					 
	$t[$i] =~ s/&#337;/õ/g;
    $t[$i] =~ s/&#369;/û/g;
 } #áéíóöõúüûÁÉ	
 return @t;
}

#*** get blocks for program files
sub getunit1 {
  my $s = shift;
  my @s = @$s;
  my $ind = shift;
  my $t = '';
  my $plen = 1;

  while ($ind < @s) {
    my $line = chompd($s[$ind]);
    $ind++;
    $t .= "$line\n";
    if ($s[$ind] =~ /^\#\*\*\*/) {last;}
  }
  return ($t, $ind);
}



#*** saves the content of the first column
sub saverut {
  my $filename = shift;  
  if (!$filename) {$filename = "$datafolder/$elang1/$folder1/$filename1.txt";}
  $filename =~ s/Latin\/tones/tones/i;

  my $newtext = $cell1->get('1.0', 'end');
  $newtext =~ s/\r\r/\r/sg;
  $newtext =~ s/\n*$/\n/;
  if (open(OUT, ">$filename")) {
     binmode OUT;
     print OUT $newtext;
     close OUT;
     $filechanged = 0;
	 saveset();         
  } else {$error .= "$datafolder/$elang1/$folder1/$filename1.txt could not be saved"}
}

sub closerut {
   $editwindow->destroy();
}

sub switchrut {
  if ($elang2 =~ /(none|search)/i) {return;}
  ($elang1, $elang2) = ($elang2, $elang1);
  ($folder1, $folder2) = ($folder2, $folder1);
  $prefix1 = $prefix2 = '';
  ($filename1, $filename2) = ($filename2, $filename1);
  editrut();
}          

#*** getfolders($lang, $folder, $prefix, $filename)
# collects the list of files for the selected $lang, $folder matching $prefix
# returns the reference of the colleted files and the default filename
sub getfolders {
  my ($lang, $folder, $prefix, $filename) = @_;
  my @files = splice(@files, @files);
  $flag = 0;
  $flag1 = 0;  

  if ($folder =~ /program/i) {$dirname = "$Bin"; $ext = "pl";}
  elsif($folder =~ /tones/i) {$dirname = "$datafolder/tones"; $ext = "txt";}
  else {$dirname = "$datafolder/$lang/$folder"; $ext = "txt"}   
  
  if (opendir(DIR, $dirname)) {
    @item = readdir(DIR);
    closedir DIR;
    foreach $item (@item) {if ($item =~ /^$prefix/i) {$flag1 = 1;}}
    if (!$flag1) {$prefix = '';}	#wrong prefix
    foreach $item (@item) {   
      if ($item =~ /.$ext$/i && (!$prefix || $item =~ /^$prefix/i)) {
        $item =~ s/\.$ext$//;
        if ($filename && $item =~ /^$filename$/) {$flag = 1;}
        push(@files, $item);
      }
    }
  }	   
  
  @files = sort(@files);
  if (!$flag) {
    $filename = '';
    if ($folder =~ /Tempora/i) {$filename = "$dayname[0]-$dayofweek";}
    if ($folder =~ /Sancti/i) {$filename = get_sday_e($month, $day, $year);}
    if ($folder =~ /Tempora/i && $dayofweek > 0 && $monthday) {$filename = $monthday;}
    if ($folder =~ /martyr/i) {$filename = nextday($month, $day, $year);}
    if ($folder =~ /commune/i) {
      if ($winner{Rank} =~ /C[0-9]+/) {$filename = $&}
      elsif ($commemoratio{Rank} =~ /C[0-9]+/) {$filename = $&;} 
    }
    if (!$filename) {$filename = $files[0];}
  }
  
  $flag = 0;
  foreach $item (@files) {if ($item =~ /^$filename$/) {$flag = 1;}}
  if (!$flag) {$filename = $files[0];}
  return (\@files, $filename, $prefix);
}	  

sub setlabel {
  my $widget = shift;
  my $str = shift;
  my $row = shift;
  $column = shift;

  my $label = $widget->Label(-text=>$str, -borderwidth=>0)
      ->grid(-row=>$row, -column=>$column, -padx=>$padx);

  configure($label, $framecolor, $smallblack);
}


sub setcheckbox {
  my $widget = shift;
  my $str = shift;
  my $var = shift;

  my $label = $widget->Label(-text=>$str)->pack(-side=>'left');
  configure($label, $framecolor, $smallblack);
  my $check = $widget->Checkbutton(-variable=>$var, -command=>sub{editrut();})->pack(-side=>'left');
  configure($check, $framecolor, $blackfont);
  my $label = $widget->Label(-text=>'  ')->pack(-side=>'left');
  configure($label, $framecolor, $smallblack);
  return $check;
}

sub setbutton {
  my $widget = shift;
  my $str = shift;
  my $command = shift;
  my $flag = shift;

  $state = ($flag) ? 'normal' : 'disabled';
  my $but = $widget->Button(-text=>$str, -borderwidth=>0, -command=>$command, -state=>$state)
    ->pack(-side=>'left', -ipadx=>$padx);
  configure($but, $framecolor, $blackfont, $blue);
  return $but;
}

sub seteditcell {
  my $row = shift;
  my $column = shift;


  $blackfontsize = 11;
  my $font = '{Arial}';
  if ($blackfont =~ /(\{.*?\})\s*([0-9]+)/) {$blackfontsize = $2; $font = "$1 $2";}

  my $cellwidth = ($elang2 =~ /none/i) ? $mw->width * .8 : $mw->width * .4;
  my $linewidth = floor($cellwidth / $blackfontsize *1.125); 
  my $fheight = $mw->fontMetrics($font, -linespace);
  my $height = floor($mw->height * .8 / $fheight); 
			  
  #creates cell
  my $cell;
  if (!$edit1 || $column == 1) { 
    $cell = $editframe->Scrolled('ROText', -scrollbars=>'e', -background=>$bgcolor, 
      -width=>$linewidth, -height=>$height, -borderwidth=>0,
      -highlightthickness=>$border, -relief=>'solid', -wrap=>'word') 
	  ->grid(-row=>$row, -column=>$column, -sticky=>'ns');
    configure($cell, $bgcolor, $blackfont);
	  
  } else {	   
    $cell = $editframe->Scrolled('Text', -scrollbars=>'e', -background=>$bgcolor, 
      -width=>$linewidth, -height=>$height, -borderwidth=>0,
      -highlightthickness=>$border, -relief=>'solid', -wrap=>'word') 
	  ->grid(-row=>$row, -column=>$column, -sticky=>'ns'); 
    configure($cell, 'white', $blackfont);
  }

  $cell->bind('<MouseWheel>' => sub{edit_scroll($cell);});
  $cell->tagConfigure('black', -foreground=>$black);
  $cell->tagConfigure('red', -foreground=>$red);

  return ($cell, $linewidth);
}

sub edit_scroll {	
  my $cell = shift;
  if ($Tk::event->D > 0) {$cell->yview('scroll', "-$scrollamount", 'units');}
	else {$cell->yview('scroll', "$scrollamount", 'units');}
}  

sub editcellout {
  my $cell = shift;
  my $text = shift;
  my $linewidth = shift;
  my $ind;

  while ($text =~ /\|(.*?)\|/) {
    my $o1 = $`;
	my $o2 = $1;
	$text = $';   

    if ($o1) {
	  $ind = $cell->index('insert');	  
      $cell->insert($ind, $o1, 'black');
    }
	$ind = $cell->index('insert');	  
    $cell->insert($ind, $o2, 'red');
  }

  $ind = $cell->index('insert');	  
  $cell->insert($ind, $text, 'black'); 
}

sub edit_destroy {
  $editwindow = '';
  $edittop = '';
  $editframe = '';
}

sub searchrut {
  $searchtext = '';
  my ($line, $text);
  $searchnum = 0;
  @searcharray = splice(@searcharray, @searcharray);
  if (!$search) {return;}
  $skeleton = 0;

  my $casesense = ($search =~ /[A-Z]/) ? 1 : 0;

  $searchlang = $elang1;
  $searchfolder = $folder1;
  $searchprefix = $prefix1;

  $searchtext = "$search found in $elang1/$folder1 files with prefix $prefix1:\n\n";
  $ext = ($folder1 =~ /program/i) ? 'pl' : 'txt';
  foreach $fname (@files1) {
    my $filename = ($folder1 =~ /program/i) ?  "$Bin/$fname.pl" :
  	  "$datafolder/$elang1/$folder1/$fname.txt";
    if (open(INP, $filename)) {
	  $text = '';
	  while ($line = <INP>) {$text .= $line;}     
      close INP;   		
    } else {$error .= "$filename cannot open";}   
	my $num = 0;
    if (!$key) {while (($casesense && $text =~ /$search/g) ||
	  (!$casesense && $text =~ /$search/ig)) {$num++;}}
	else {$num = countskey($text, $key, $casesense);}
	if ($num) {push(@searcharray, "$fname.$ext = $num");}
  }
  foreach $line (@searcharray) {$searchtext .= "$line\n";}	
  nextrut();
}

sub nextrut {
  if (!@searcharray) {$searchnum = 0; editrut();}
  if ($searchnum >= @searcharray) {$searchnum = 0;}
  $searchline = $searcharray[$searchnum];
  $searchnum++;
  if ($searchline =~ /\.(pl|txt)/i) {$filename1 = $`;}
  $elang1 = $searchlang;
  $folder1 = $searchfolder;
  $prefix1 = $searchprefix;
  
  editrut();
}

sub countskey {
  my $text = shift;
  my $skey = shift;
  my $casesense = shift;

  my @t = split("\n", $text);
  my $line;
  my $flag = 0;
  my $count = 0;
  foreach $line (@t) {
    if ($line =~ /^\s*\[$skey\]/i) {$flag = 1; next;}
	elsif($line =~ /^\s*\[[a-z0-9\-\_ ]+\]/i) {$flag = 0; next;}
	if ($flag) {while (($casesense && $line =~ /$search/g) || (!$casesense && $line =~ /$search/ig))
    {$count++;}}
  }		 
  return $count;
}


sub findrut {
 my $cell = shift;
 my $search = shift;

 my $text = $cell->get('1.0', 'end');	
 my @text = split("\n", $text);
 my $casesense = ($search =~ /[A-Z]/) ? 1 : 0;	   
 my $len = length($search);
 $cell->tagConfigure('gray', -background=>$voicegrey1);
 my $first = 1;

 my $i;
 for ($i = 0; $i < @text; $i++) {
   if (($casesense && $text[$i] =~ /$search/) || (!$casesense && $text[$i] =~ /$search/i)) {
     my $j = $i + 1;
	 my $len1 = length($`);
	 my $len2 = $len1 + $len;
     $cell->tagAdd('gray', "$j.$len1", "$j.$len2");
	 if ($first) {$cell->yview("$j.$len2"); $first = 0;}
   }
 }

}

sub saveset {
  if (!$savebutton || !Exists($savebutton)) {return;}
  if ($filechanged) {$savebutton->configure(-state=>'normal');}
  else {$savebutton->configure(-state=>'disabled');}
}

sub savedialog {    
  my $dia = $editwindow->Dialog(-title=>'File changed', -text=>'Save file', -default_button=>'Yes',
    -buttons=>['Yes', 'No']);
  if ($dia->Show() =~ /Yes/i) {saverut($editfilename);}
  $filechanged = 0;
  saveset();
}
  
#*** get_sday_e($month, $day, $year)
#get filename for saint for the given date
sub get_sday_e {
  my ($month, $day, $year) = @_;
  my $fname = get_sday($month, $day, $year); 
  if ($version =~ /1570/ && (-e "$datafolder/Latin/Sancti/$fname" . "o.txt")) {return $fname . 'o';}
  if ($version =~ /Trident/i && (-e "$datafolder/Latin/Sancti/$fname" . "t.txt")) {return $fname . 't';}
  if ($version =~ /Newcal/i && (-e "$datafolder/Latin/Sancti/$fname" . "n.txt")) {return $fname . 'n';}
  if ($version =~ /1960/ && (-e "$datafolder/Latin/Sancti/$fname" . "r.txt")) {return $fname . 'r';}
  if (!(-e "$datafolder/Latin/Sancti/$fname.txt") && $winner =~ /Sancti\/(.*?)\.txt/) {$fname = $1;} 
  return $fname;
}

sub lcompare {
  my $t1 = shift;
  my $t2 = shift;
  my $str = " (";

  my @t1 = split("\n", $t1);
  my @t2 = split("\n", $t2);
  my ($n1, $n2, $i, $j);

  my $sum = 0;
  my $esum = 0;
  my $n = @t1;
  if ($n < @t2) {$n = @t2;}

  for ($i = 1; $i < $n; $i++) {
    my $l1 = $t1[$i];
	my @l1 = split(' ', $l1);
	$n1 = @l1;
	my $l2 = $t2[$i];
	my @l2 = split(' ', $l2);
	$n2 = @l2;
    my $m = $l1;
	if ($n2 > $m) {$m = $n2;}
    $flag = 0;
	for ($j = 0; $j < $m; $j++) 
	  {if (deaccent($l1[$j]) ne deaccent($l2[$j])) {$flag++;}} 
	 
	if ($n1 == $n2 && !$flag) {$str .= "$n1,";}
	else {$str .= "|$n1|,";}
	$sum .= $n1;
	$esum += $flag;
  }
  $n1 = @t1 -1;
  $n2 = @t2 - 1;
  if ($n1 == $n2 && !$esum) {$str .= ") $n1";}
  elsif (!$esum) {$str .= ") |$n1|";}
  else {$str .= ") $n1 |$esum|";}
  return $str;
}

sub tcompare {
  my $t1 = shift;
  my $t2 = shift;
  if (!$t2 || !$t1) {return $t1;} 

  my @t1 = split(' ', $t1);
  my @t2 = split(' ', $t2); 
  my $n = @t1;
  if ($n < @t2) {$n = @t2;}
  my ($w1, $w2, $i);
  my $str = '';

  for ($i = 0; $i < $n; $i++) {
    $w1 = deaccent($t1[$i]);  
	$w2 = deaccent($t2[$i]);  
	
	if ($w1 eq $w2) {$str .= "$t1[$i] ";}
	else {$str .= "|$t1[$i]| ";}
 }
 return $str;
}
	

sub deaccent {
  my $w = shift; 

  $w =~ s/[!@#$%&*()\-_=+,<.>?'";:0-9 ]//g; 
  
  $w =~ s/á/a/g;
  $w =~ s/é/e/g;
  $w =~ s/í/i/g;
  $w =~ s/ó/o/g;
  $w =~ s/ú/u/g;
  $w =~ s/Á/A/g;
  $w =~ s/É/E/g;
  $w =~ s/Í/I/g;
  $w =~ s/Ó/O/g;
  $w =~ s/Ú/U/g;
  $w =~ s/ae/æ/g;
  $w =~ s/áe/æ/g;
  $w =~ s/oe/œ/g;
  $w =~ s/óe/œ/g;
  $w =~ s/Ae/Æ/g;
  $w =~ s/Áe/Æ/g;
  $w =~ s/Oe/Œ/g; 
  $w =~ s/Óe/Œ/g;
  $w =~ s/ı/y/g;
  $w =~ s/([nraeiouáéíóöõúüûÁÉÓÖÔÚÜÛ])i([aeiouáéíóöõúüûÁÉÓÖÔÚÜÛ])/$1j$2/ig;
  $w =~ s/^i([aeiouAEIOUáéíóöõúüûÁÉÓÖÔÚÜÛ])/j$1/g; 
  $w =~ s/^I([aeiouAEIOUáéíóöõúüûÁÉÓÖÔÚÜÛ])/J$1/g; 
  return $w;
}


#áéíóöõúüûÁÉÓÖÔÚÜÛ
sub putaccents {
  my $t = shift;
  $t =~ s/''/ '/;
  
  $t =~ s/a'/á/g;
  $t =~ s/e'/é/g;
  $t =~ s/i'/í/g;
  $t =~ s/o'/ó/g;
  $t =~ s/o:/ö/g;
  $t =~ s/o"/õ/g;
  $t =~ s/u'/ú/g;
  $t =~ s/u:/ü/g;
  $t =~ s/u"/û/g;
  $t =~ s/A'/Á/g;
  $t =~ s/E'/É/g;
  $t =~ s/&#337;/õ/g;
  $t =~ s/&#369;/û/g;
  $t =~ s/O'/Ó/g;
  $t =~ s/O:'/Ö/g;
  $t =~ s/O:/Ô/g;
  $t =~ s/U'/Ú/g;
  $t =~ s/U:/Ü/g;
  $t =~ s/U"/Û/g;
  $t =~ s/y'/ı/g;

  return $t;
}