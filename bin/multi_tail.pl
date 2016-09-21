#!/usr/bin/env perl

use strict;
use warnings;

use Term::ANSIColor qw/:constants/;
use File::Tail;
use POSIX qw//;
use YAML;

BEGIN{
    $Term::ANSIColor::AUTORESET = 1;
};

$SIG{INT} = sub {
    print Term::ANSIColor::color('reset');
    exit;
};

my $config = eval{
    YAML::LoadFile('./etc/config.yaml');
};
if( $@ ){
    die "parse config failed. $@";
}

my @target_list = map{
    my $file = $_;
    my $file_name = _generate_filename($file->{path});
    my $tail = File::Tail->new( set_option($file_name, $file->{option}) );
    { file => $tail , color => $file->{color} };
} @{$config};

while(1){
    for my $target ( @target_list ){
        my $line = $target->{file}->read;
        next unless defined $line;
        print Term::ANSIColor::color($target->{color}). $line;
    }
};

sub _generate_filename {
    my $file_name = shift;
    return POSIX::strftime($file_name, localtime(time()));
}

sub set_option{
    my ($file_name, $option) = @_;
    # EN : http://search.cpan.org/~mgrabnar/File-Tail-1.3/Tail.pm#CONSTRUCTOR
    # JA : http://perldoc.jp/docs/modules/File-Tail-0.98/Tail.pod
    return (
         maxinterval        => 1,
         reset_tail         => 1,
         tail               => 1,
         nowait             => 1,
         ignore_nonexistant => 1,
         name               => $file_name,
         defined $option ? %{$option} : (),
    );
}

__END__

=encoding UTF-8

=head1 NAME

multi_tail.pl

=head1 DESCRIPTION

    * tail files ( written in $REPOS/etc/config.yaml )
    * stop by CTRL + C

=head1 etc/config.yaml Format

    * Check by `make test`
    * Must be returned ArrayRef
    * ArrayRef has HashRef
    * HashRef has some pair
        * path: '/path/to/log/log_file%Y_%m_%d_%H_%M.log'
                   # REQUIRED
                   # full file path
                   # path can be written with POSIX format 
        * color: 'red'
                   # REQUIRED
                   # color is choosen from Term::ANSIColor 
        * option:
            ignore_nonexistant: 0
                   # OPTIONAL
                   # pairs are choosen from File::Tail
                   # Default options are set in this script, but this options are preferred


=cut
