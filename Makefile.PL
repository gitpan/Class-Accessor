use ExtUtils::MakeMaker;

# $LAST_API_CHANGE = '0.10';
require 5.00502;

WriteMakefile(
    NAME                => 'Class::Accessor',
    VERSION_FROM        => 'lib/Class/Accessor.pm',
    PREREQ_PM           => { base => $] == 5.006 ? 1.02 : 1.01, },
);
