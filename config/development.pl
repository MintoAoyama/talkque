use File::Spec;
use File::Basename qw(dirname);
my $basedir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $dbpath = File::Spec->catfile($basedir, 'db', 'development.db');
+{
    'DBI' => [
        "dbi:SQLite:dbname=$dbpath", '', '',
        +{
            sqlite_unicode => 1,
        }
    ],
    'spreadsheet' => {
		key => '',
		title => 'Sheet1',
        label => {
            pub_date => '発表日',
        },
	},
    'menu' => [ {
            url => '',
            title => 'Sheet1',
        },
    ],
    'endtime' => '14:00',
};
