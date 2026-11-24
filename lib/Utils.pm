package Utils;

use v5.40.0;

use strict;
use warnings;

use Exporter qw< import >;
our @EXPORT_OK = qw<
    add_job_summary
    list_issue
    view_issue
    edit_issue
    create_issue
    close_issue
>;

my $repo = $ENV{GITHUB_REPOSITORY};

if ( !defined $repo ) {
    warn "Repository name is not defined\n";
    exit 1;
}

sub add_job_summary ($msg)
{
    my $fname = $ENV{GITHUB_STEP_SUMMARY} // '';

    open my $fh, '>>', $fname
      or die "Failed to append to $fname: $!";

    print $fh "$msg\n";
    close $fh or die $!;
}

sub list_issue (%opts)
{
    my ( $type, $search, $label, $target ) = @opts{ qw< type search label target > };

    my @cmd = (
        'gh',
        'issue list',
        '--repo',   $repo,
        '--search', qq{"author:app/aur-bump-bot '$search' in:title"},
        '--label',  qq{'$label'},
        '--state',  'open',
        '--limit',  '1',
        '--json',   'number',
        '--jq',     '.[].number',
    );

    chomp( my $issue_num = qx(@cmd) );

    if ( $? == 0 ) {
        return $issue_num;
    }
    else {
        warn "$target: failed to check $type issue for $target\n";
        exit 1;
    }
}

sub view_issue ( $type, $issue_num, $target )
{
    my @cmd = (
        'gh',
        'issue',
        'view',
        $issue_num,
        '--repo', $repo,
        '--json', 'body',
        '--jq',   '.body',
    );

    chomp( my $issue = qx(@cmd) );

    if ( $? == 0 ) {
        return $issue;
    }
    else {
        warn "$target: failed to request $type issue #$issue_num\n";
        exit 1;
    }
}

sub edit_issue (%opts)
{
    my ( $type, $issue_num, $title, $body, $target ) = @opts{ qw< type issue title body target > };

    print "$target: updating $type issue #$issue_num with new versions\n";

    my @cmd = (
        'gh',
        'issue',
        'edit',
        $issue_num,
        '--repo',  $repo,
        '--title', $title,
        '--body',  $body,
    );

    system(@cmd) == 0
      or do {
          warn "$target: failed to update $type issue #$issue_num\n";
          exit 1;
      };

    my $msg = "- Updated $type issue #$issue_num for $target";
    add_job_summary($msg);
}

sub create_issue (%opts)
{
    my ( $type, $label, $title, $body, $target ) = @opts{ qw< type label title body target > };

    print "$target: creating $type issue\n";

    my @cmd = (
        'gh',
        'issue',
        'create',
        '--repo',  $repo,
        '--label', $label,
        '--title', $title,
        '--body',  $body,
    );

    system(@cmd) == 0
      or do {
          warn "$target: failed to create $type issue\n";
          exit 1;
      };

    my $msg = "- Created $type issue for $target";
    add_job_summary($msg);
}

sub close_issue (%opts)
{
    my ( $type, $issue_num, $pkgver, $target ) = @opts{ qw< type issue pkgver target > };

    print "$target: closing existing issue #$issue_num\n";

    my @cmd = (
        'gh',
        'issue',
        'close',
        $issue_num,
        '--repo',    $repo,
        '--comment', "Current version $pkgver is latest, closing the issue.",
    );

    system(@cmd) == 0
      or do {
          warn "$target: failed to close $type issue #$issue_num\n";
          exit 1;
      };

    my $msg = "- Closed $type issue #$issue_num for $target";
    add_job_summary($msg);
}
