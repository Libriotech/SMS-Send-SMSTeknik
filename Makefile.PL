use 5.008000;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'SMS::Send::SMSTeknik',
    VERSION_FROM      => 'lib/SMS/Send/SMSTeknik.pm',
    PREREQ_PM         => { LWP::UserAgent => 0, SMS::Send::Driver => 0 },
    NO_META           => 1,
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
        (ABSTRACT_FROM  => 'lib/SMS/Send/SMSTeknik.pm',
            AUTHOR         => 'Magnus Enger <magnus@libriotech.no>') : ()),
);
