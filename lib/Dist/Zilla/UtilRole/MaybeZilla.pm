use strict;
use warnings;

package Dist::Zilla::UtilRole::MaybeZilla;

# ABSTRACT: Soft-dependency on Dist::Zilla for Utilities.

=head1 DESCRIPTION

C<Dist::Zilla> Is Great. Long Live C<Dist::Zilla> But when you're writing a utility class,
loading C<Dist::Zilla> may be not necessary, and can make testing things harder.

Namely, because to test anything that B<requires> C<Dist::Zilla>, B<requires> that you
have a valid build tree, which may be lots of unnecessary work if you only need C<dzil> for
simple things like error logging.

Or perhaps, you have other resources that you only conventionally fetch from C<dzil>,
such as the C<dzil build-root>, for the sake of making a C<Git::Wrapper>, but you're quite
happy with passing C<Git::Wrapper> instances directly for testing.

And I found myself doing quite a lot of the latter, and re-writing the same code everywhere to do it.

So, this role provides a C<zilla> attribute that is B<ONLY> required if something directly calls C<< $self->zilla >>, and it fails on invocation.

And provides a few utility methods, that will try to use C<zilla> where possible, but fallback to
a somewhat useful default if those are not available to you.

    package MyPlugin;
    use Moose;
    with 'Dist::Zilla::UtilRole::MaybeZilla';

    ...

    sub foo {
        if ( $self->has_zilla ) {
            $self->zilla->whatever
        } else {
            $slightlymessyoption
        }
    }

Additionally, it provides a few compatibility methods to make life easier, namely

    log_debug, log, log_fatal

Which will invoke the right places in C<dzil> if possible, but revert to a sensible
default if not.

=cut

use Moose::Role;
use Scalar::Util qw(blessed);
use namespace::autoclean;
use Log::Contextual::LogDispatchouli qw(log_fatal);

=attr C<zilla>

A lazy attribute, populated from C<plugin> where possible, C<die>ing if not.

=attr C<plugin>

A lazy attribute that C<die>s if required and not specified.

=cut

has zilla  => ( isa => Object =>, is => ro =>, predicate => has_zilla  => lazy_build => 1 );
has plugin => ( isa => Object =>, is => ro =>, predicate => has_plugin => lazy_build => 1 );

sub _build_zilla {
  my ($self) = @_;
  if ( $self->has_plugin and $self->plugin->can('zilla') ) {
    return $self->plugin->zilla;
  }
  return log_fatal {
    'Neither `zilla` or `plugin` were specified, and one must be specified to ->new() for this method';
  };
}

sub _build_plugin {
  my ($self) = @_;
  return log_fatal {
    '`plugin` needs to be specificed to ->new() for this method to work';
  };
}

=head1 FOOTNOTES

I had intended to have logging methods on this, but they proved too messy and problematic.

More, I discovered the way Dist::Zilla handles logs is kinda problematic too, because you may have noticed,

    $self->log_fatal()

May just have a predisposition from reporting the failure context being

    Moose/Method/Deferred.pm

Most cases. ( ☹ )

So I'm experimentally toying with using more L<< C<Log::Contextual>|Log::Contextual >>.

See L<< C<[LogContextual]>|Dist::Zilla::Plugin::LogContextual >>

=cut

no Moose::Role;

1;
