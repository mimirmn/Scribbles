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
use DBI;

use CGI;

my $cfn = "";
 
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

my $connect = $menubar->cascade(-label => '~Connect');
my $createblog = $menubar->cascade(-label => '~Create Blog');

$file->separator; 

$file->command(-label => 'New', -accelerator => 'Ctrl-n', -underline => 0, -command => \&newFile);
$file->separator;
$file->command( -label => 'Open', -accelerator => 'Ctrl-o', -underline => 0, -command=> \&getFile); 
$file->separator; 
$file->command( -label => 'Save', -accelerator => 'Ctrl-s', -underline => 0, -command=> \&saveFile ); 
$file->command( -label => 'Save As ...', -accelerator => 'Ctrl-a', -underline => 1, );
$file->separator; 
$file->command( -label => "Close", -accelerator => 'Ctrl-w', -underline => 0, -command => \&closeFile ); 
$file->separator; $file->command( -label => "Quit", -accelerator => 'Ctrl-q', -underline => 0, -command => \&exit, );

$edit->command(-label => 'Preferences ...'); 
$help->command(-label => 'Version', -command => sub {print "Version\n"}); 
$help->separator; 
$help->command(-label => 'About', -command => sub {print "About\n"});

$connect->command(-label => 'Connect', -accelerator => 'Ctrl-xc', -underline => 0, -command => \&connectDB);

$createblog->command(-label => 'Create Blog', -accelerator => 'Ctrl-xc', -underline => 0, -command => \&createblog);





my $text = $top->Text(
    -state => 'disable',
    -font => ['fixed', 20],
    -background => 'Blue',
    
);
$text->pack;


my $table  = $top->Table(-columns => 3, -rows => 8, -fixedrows => 1, -scrollbars => 'se');
$table->pack(-expand=> 1, -fill => 'both');

#foreach my $col (0..1) {
#    foreach $row (0..7) {
#        my $btn = $table->Button(
#            -text => "Entry $row, $col",
#            -command => [\&click, $table , $row ,$col],
#        );
#        $table->put($row, $col, $btn);
#    }
#}



my $sqlabel = $table->Label(
-text => 'SQL Statement',


);

$table->put(1,1,$sqlabel);
#$sqlabel->pack (-side => 'left');

my $sqlentry = $table->Entry(
-font => ['fixed', 20],

);
#$sqlentry->pack;

$table->put(1,2,$sqlentry);

my $sqlbtn2 = $table->Button(
    -text    => 'EXECUTE SQL STATEMENT',
    -font    => ['fixed', 20],
    -command => \&freshSQL,
);
#$sqlbtn->pack;
$table->put(1,3,$sqlbtn2);



my $unlabel = $table->Label(
-text => 'Username',


);

#$unlabel->pack (-side => 'left');

$table->put(2,1,$unlabel);

my $unentry = $table->Entry(
-font => ['fixed', 20],

);

#$unentry->pack;

$table->put(2,2,$unentry);

my $pwlabel = $table->Label(
-text => 'Password',


);
#$pwlabel->pack (-side => 'left');
$table->put(3,1,$pwlabel);

my $pwentry = $table->Entry (
-font => ['fixed', 20],

);

#$pwentry->pack;

$table->put(3,2,$pwentry);

my $sqlbtn = $table->Button(
    -text    => 'CREATE NEW USER',
    -font    => ['fixed', 20],
    -command => \&updateDB,
);
#$sqlbtn->pack;
$table->put(3,3,$sqlbtn);






my $entry = $table->Entry(
-font => ['fixed', 20],

);
$table->put(4,1,$entry);

#$entry->pack;




my $btn = $table->Button(
    -text    => 'Enter Text',
    -font    => ['fixed', 20],
    -command => \&do_on_click,
);
#$btn->pack;

$table->put(4,2,$btn);

$entry->bind('<Return>',sub {sendLog("enter");});


sub createblog {

my $db = 'userdb';
my $username = 'root';
my $password = '';
my $host = '127.0.0.1';
my $port = '3310';
my $auth = "";
my $socket = "/opt/lampp/var/mysql/mysql.sock";

#my $dsn = "DBI:mysql:database=$db;mysql_socket=$socket";
#my $dsn = "DBI:MariaDB:database=$db;mariadb_socket=$socket";
my $dsn = "DBI:MariaDB:database=$db;host=$host;port=$port";
         my $dbh = DBI->connect($dsn, $username, $password);




if(!$dbh){




$text->Insert("Failed to connect to MySQL database DBI->errstr()\n");
die;

}else{



$text->configure('background', 'Gray');
# $text->Insert("Connected to MySQL server successfully. \n");


}



$text->configure('background', 'Gray');

my $un = $unentry->get;
my $pw = $pwentry->get;
$text->selectAll;
my $pc = $text->getSelected;

my $stment = "INSERT INTO blogs (title, author, postcontents) VALUES ('$un','$pw', '$pc');";
$text->Insert($stment."\n");

my $sth = $dbh->prepare($stment)
                   or die $text->Insert("Prepare statement failed: $dbh->errstr()\n");

$sth->execute() or die $text->Insert("Execution failed: $dbh->errstr()\n"); 


$text->unselectAll;

#print "<table border=\"1\">\n";

# table headings are SQL column names

#$text->Insert("ID | USERNAME | PASSWORD | TIMESTAMP \n");
#while (my @row = $sth->fetchrow_array) {
#    $text->Insert("$row[0] | $row[1] | $row[2] | $row[3]\n");
#}




$sth->finish();
$dbh->disconnect();






}


sub freshSQL {


my $db = 'userdb';
my $username = 'root';
my $password = '';
my $host = '127.0.0.1';
my $port = '3310';
my $auth = "";
my $socket = "/opt/lampp/var/mysql/mysql.sock";

#my $dsn = "DBI:mysql:database=$db;mysql_socket=$socket";
#my $dsn = "DBI:MariaDB:database=$db;mariadb_socket=$socket";
my $dsn = "DBI:MariaDB:database=$db;host=$host;port=$port";
         my $dbh = DBI->connect($dsn, $username, $password);




if(!$dbh){

$text->configure('state', 'normal');
$text->delete("1.0", 'end');

$text->configure('background', 'Gray');
$text->Insert("Failed to connect to MySQL database DBI->errstr()\n");
die;

}else{

$text->configure('state', 'normal');
$text->delete("1.0", 'end');

$text->configure('background', 'Gray');
 $text->Insert("Connected to MySQL server successfully. \n");


}

$text->configure('state', 'normal');
$text->delete("1.0", 'end');

$text->configure('background', 'Gray');

#my $stment = $sqlentry->get;
#my $stment = "INSERT INTO userauth (username, pwd) VALUES ('$un','$pw');";

my $stment = $sqlentry->get;

$text->Insert($stment."\n");

my $sth = $dbh->prepare($stment)
                   or die $text->Insert("Prepare statement failed: $dbh->errstr()\n");

$sth->execute() or die $text->Insert("Execution failed: $dbh->errstr()\n"); 


while (my @row = $sth->fetchrow_array) {
    $text->Insert("$row[0] | $row[1] | $row[2] | $row[3]\n");
}





$sth->finish();
$dbh->disconnect();




}

sub updateDB {

my $db = 'userdb';
my $username = 'root';
my $password = '';
my $host = '127.0.0.1';
my $port = '3310';
my $auth = "";
my $socket = "/opt/lampp/var/mysql/mysql.sock";

#my $dsn = "DBI:mysql:database=$db;mysql_socket=$socket";
#my $dsn = "DBI:MariaDB:database=$db;mariadb_socket=$socket";
my $dsn = "DBI:MariaDB:database=$db;host=$host;port=$port";
         my $dbh = DBI->connect($dsn, $username, $password);




if(!$dbh){

$text->configure('state', 'normal');
$text->delete("1.0", 'end');

$text->configure('background', 'Gray');
$text->Insert("Failed to connect to MySQL database DBI->errstr()\n");
die;

}else{

$text->configure('state', 'normal');
$text->delete("1.0", 'end');

$text->configure('background', 'Gray');
 $text->Insert("Connected to MySQL server successfully. \n");


}

$text->configure('state', 'normal');
$text->delete("1.0", 'end');

$text->configure('background', 'Gray');

my $un = $unentry->get;
my $pw = $pwentry->get;
my $stment = "INSERT INTO userauth (username, pwd) VALUES ('$un','$pw');";
$text->Insert($stment."\n");

my $sth = $dbh->prepare($stment)
                   or die $text->Insert("Prepare statement failed: $dbh->errstr()\n");

$sth->execute() or die $text->Insert("Execution failed: $dbh->errstr()\n"); 




#print "<table border=\"1\">\n";

# table headings are SQL column names

#$text->Insert("ID | USERNAME | PASSWORD | TIMESTAMP \n");
#while (my @row = $sth->fetchrow_array) {
#    $text->Insert("$row[0] | $row[1] | $row[2] | $row[3]\n");
#}




$sth->finish();
$dbh->disconnect();




}

sub connectDB {

my $db = 'userdb';
my $username = 'root';
my $password = '';
my $host = '127.0.0.1';
my $port = '3310';
my $auth = "";
my $socket = "/opt/lampp/var/mysql/mysql.sock";

#my $dsn = "DBI:mysql:database=$db;mysql_socket=$socket";
#my $dsn = "DBI:MariaDB:database=$db;mariadb_socket=$socket";
my $dsn = "DBI:MariaDB:database=$db;host=$host;port=$port";
         my $dbh = DBI->connect($dsn, $username, $password);




if(!$dbh){

$text->configure('state', 'normal');
$text->delete("1.0", 'end');

$text->configure('background', 'Gray');
$text->Insert("Failed to connect to MySQL database DBI->errstr()\n");
die;

}else{

$text->configure('state', 'normal');
$text->delete("1.0", 'end');

$text->configure('background', 'Gray');
 $text->Insert("Connected to MySQL server successfully. \n");


}

$text->configure('state', 'normal');
$text->delete("1.0", 'end');

$text->configure('background', 'Gray');

my $sth = $dbh->prepare("SELECT * FROM userauth;")
                   or die $text->Insert("Prepare statement failed: $dbh->errstr()");

$sth->execute() or die $text->Insert("Execution failed: $dbh->errstr()"); 




#print "<table border=\"1\">\n";

# table headings are SQL column names

$text->Insert("ID | USERNAME | PASSWORD | TIMESTAMP \n");
while (my @row = $sth->fetchrow_array) {
    $text->Insert("$row[0] | $row[1] | $row[2] | $row[3]\n");
}
$text->Insert("End of Table\n");



$sth->finish();
$dbh->disconnect();




}


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
$cfn = $filename;


$text->configure('state', 'normal');
$text->delete("1.0", 'end');

$text->configure('background', 'Gray');
$text->Insert($filename . "\n");

my $stuff = read_file("$filename");

$text->Insert($stuff . "\n");

}




}

sub closeFile {
$cfn = "";

;
$text->delete("1.0", 'end');
$text->configure('background', 'Blue');
$text->configure('state', 'disable');

}

sub newFile {
$cfn = "";

$text->configure('state', 'normal');
$text->delete("1.0", 'end');
$text->configure('background', 'Gray');
#$text->Insert("New Command entered\n");
}





sub saveFile {
my $fname;
my $db;
my $answer;

if ($cfn eq "")
{

$db = $top->DialogBox(-title => 'Save', -buttons => ['Save', 'Cancel'], -default_button => 'Save'); 
$db->add('LabEntry', -textvariable => \$fname, -width => 20, -label => 'FileName', -labelPack => [-side => 'left'])->pack; 

$answer = $db->Show( ); 
#$text ->Insert("Answer is $answer\n");

       if ($answer eq "Save") 
        { 

 #         $text->Insert("Saved As  $fname"); 

$cfn = $fname;
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

if ($cfn ne "")
{

$text->selectAll;
my $str = $text->getSelected;


open(FH, '>', $cfn) or die $!;

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
