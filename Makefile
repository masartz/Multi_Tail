setup:
	bin/cpanm -l local --installdeps .

run:
	perl -I local/lib/perl5 bin/multi_tail.pl

test:
	perl -I local/lib/perl5 t/config_format.t
	
help:
	perldoc bin/multi_tail.pl
