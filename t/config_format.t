use strict;
use warnings;

use Test::More;
use Data::Util;
use YAML;

my $config;
subtest 'parse' => sub{
    $config = YAML::LoadFile('./etc/config.yaml');
    ok Data::Util::is_array_ref($config), 'parse OK';
};

subtest 'valid contents' => sub{
    for my $row ( @{$config} ){
        ok Data::Util::is_hash_ref($row), 'row is hashref';
        
        ok Data::Util::is_string($row->{path}), "[$row->{path}] is string";
        ok Data::Util::is_string($row->{color}), "[$row->{color}] is string";
        SKIP: {
            skip 'option is optional param', 1, unless exists $row->{option};
            ok Data::Util::is_hash_ref($row->{option}), 'option is hashref';
        };
    }
};

done_testing();
