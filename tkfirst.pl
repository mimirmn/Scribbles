use strict;
use warnings;
use File::Slurp;
use Tk;
use Net::CUPS;
use Data::Dumper;
use Tk::LabEntry;
use IO::File;
use Tk::DirTree;
use Cwd;
 
my $cups = Net::CUPS->new();
#my @printers = $cups->getDestinations();
my @printers = $cups->getServer();

print "printers-> @printers\n";

my $top = MainWindow->new ( 
-title => 'Scribbles',
);

$top->configure(-menu => my $menubar = $top->Menu);

my $file = $menubar->cascade(-label => '~File'); 
my $edit = $menubar->cascade(-label => '~Edit'); 
my $help = $menubar->cascade(-label => '~Help');



$file->separator; 

$file->command(-label => 'New', -accelerator => 'Ctrl-n', -underline => 0, -command => \&newFile);
$file->separator;
$file->command( -label => 'Open', -accelerator => 'Ctrl-o', -underline => 0, -command=> \&getFile); 
$file->separator; 
$file->command( -label => 'Save', -accelerator => 'Ctrl-s', -underline => 0, -command=> \&saveFile ); 
$file->command( -label => 'Save As ...', -accelerator => 'Ctrl-a', -underline => 1, );
$file->separator; 
$file->command( -label => "Close", -accelerator => 'Ctrl-w', -underline => 0, -command => \&exit, ); $file->separator; $file->command( -label => "Quit", -accelerator => 'Ctrl-q', -underline => 0, -command => \&exit, );

$edit->command(-label => 'Preferences ...'); 
$help->command(-label => 'Version', -command => sub {print "Version\n"}); 
$help->separator; 
$help->command(-label => 'About', -command => sub {print "About\n"});








my $text = $top->Text(
    -state => 'disable',
    -font => ['fixed', 20],
    -background => 'Blue',
    
);
$text->pack;

my $entry = $top->Entry(
-font => ['fixed', 20],

);
$entry->pack;




my $btn = $top->Button(
    -text    => 'Enter Text',
    -font    => ['fixed', 20],
    -command => \&do_on_click,
);
$btn->pack;

$entry->bind('<Return>',sub {sendLog("enter");});


sub getFile {
my $types = [
    ['Text Files',       ['.txt', '.text']],
    ['TCL Scripts',      '.tcl'           ],
    ['C Source Files',   '.c',      'TEXT'],
    ['GIF Files',        '.gif',          ],
    ['GIF Files',        '',        'GIFF'],
    ['All Files',        '*',             ],
];


my $filename = $top->getOpenFile(-filetypes=>$types);

if ($filename ne "")
{
$text->configure('state', 'normal');
$text->configure('background', 'Gray');
$text->Insert($filename . "\n");

my $stuff = read_file("$filename");

$text->Insert($stuff . "\n");

}




}



sub newFile {
$text->configure('state', 'normal');
$text->delete("1.0", 'end').
$text->configure('background', 'Gray');
#$text->Insert("New Command entered\n");
}

sub openFile {
my $t = $top->Toplevel;
$t->title("Choose directory:");
my $ok = 0;

my $f = $t->Frame->pack(-fill => "x", -side => "bottom");

my $curr_dir = 'd:';
#my $curr_dir = Cwd::cwd();

my $d;
$d = $t->Scrolled('DirTree',
                  -scrollbars => 'osoe',
                  -width => 35,
                  -height => 20,
                  -selectmode => 'browse',
                  -exportselection =>1,
                  -browsecmd => sub { $curr_dir = shift },
                  -command => sub { $ok = 1; },
                 )->pack(-fill => "both", -expand => 1);

$d->chdir($curr_dir);

$d->chdir($curr_dir);

$f->Button(-text => 'Ok',
           -command => sub { $ok = 1 })->pack(-side => 'left');
$f->Button(-text => 'Cancel',
           -command => sub { $ok = 1 })->pack(-side => 'left');

$f->waitVariable(\$ok);


}

sub saveFile {
my $fname;
my $db;
my $answer;

$db = $top->DialogBox(-title => 'Save', -buttons => ['Save', 'Cancel'], -default_button => 'Save'); 
$db->add('LabEntry', -textvariable => \$fname, -width => 20, -label => 'FileName', -labelPack => [-side => 'left'])->pack; 

$answer = $db->Show( ); 
#$text ->Insert("Answer is $answer\n");

       if ($answer eq "Save") 
        { 

 #         $text->Insert("Saved As  $fname"); 

#my $output = IO::File->new(">$fname");
#my $filename = 'c:\temp\test3.txt';
$text->selectAll;
my $str = $text->getSelected;
#my $fn = "\home\dad\". $fname;

open(FH, '>', $fname) or die $!;

print FH $str;

close(FH);

#$text->Insert("Wrote this to file: ". $str);

$text->unselectAll;
$text->configure('background', 'Blue');
$text->configure('background', 'Gray');


            } 

}

sub sendLog{
    $text->configure('state', 'normal');
    $text->Insert($entry->get . "\n");
    my $len = length($entry->get);
    #$text->Insert("Length is $len \n");
    $entry->delete('0','end');
    $text->configure('state', 'normal')
}

sub do_on_click {
    $text->configure('state', 'normal');
    $text->Insert($entry->get . "\n");
    my $len = length($entry->get);
    #$text->Insert("Length is $len \n");
    $entry->delete('0','end');
    $text->configure('state', 'normal');
}


#$text->Insert("printers-> @printers\n");




MainLoop;
