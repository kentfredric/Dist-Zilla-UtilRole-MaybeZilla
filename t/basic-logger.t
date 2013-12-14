
use strict;
use warnings;

use Test::More;

# FILENAME: basic-logger.t
# CREATED: 12/14/13 17:07:05 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Basic logger functionality test

{
    package Dist::Zilla::Util::Example;
    use Moose;
    with 'Dist::Zilla::UtilRole::MaybeZilla';

    __PACKAGE__->meta->make_immutable;
    $INC{'Dist/Zilla/Util/Example.pm'} ||= 1;
}

use Test::Fatal qw( exception );

my $instance;
my $e = exception {
    $instance = Dist::Zilla::Util::Example->new();
};
is( $e, undef, 'Instantiation ok') or diag explain $e;
my $logger;
$e = exception {
    $logger = $instance->logger;
};
is( $e, undef, 'Getting logger ok') or diag explain $e;

use Capture::Tiny qw(capture);
my ($stdout,$stderr);

subtest 'log' => sub {
    ($stdout,$stderr,$e) = capture {
        exception {
            $instance->log("This is a log line");
        };
    };

    is( $e, undef, 'Logging ok') or diag explain $e;
    like($stdout, qr/This is a log line/, 'logged line is in stdout');

    note explain { stdout => $stdout, stderr => $stderr };
};

subtest 'log_debug' => sub {
    ($stdout,$stderr,$e) = capture  {
        exception {
            $instance->log_debug("This is a debug log line");
        };
    };

    is( $e, undef, 'log_debug ok') or diag explain $e;
    note explain { stdout => $stdout, stderr => $stderr };

};

subtest 'log_fatal' => sub {
    ($stdout,$stderr,$e) = capture  {
        exception {
            $instance->log_fatal("This is a fatal log line");
        };
    };
    isnt( $e, undef, 'log_fatal bails') and diag explain $e;
    note explain { stdout => $stdout, stderr => $stderr };
};

done_testing;


