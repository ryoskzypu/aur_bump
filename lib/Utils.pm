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
    warn 'Repository name is not defined';
    exit 1;
}

sub _err ($msg)
{
    warn "$msg\n";
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
        _err("$target: failed to check $type issue for $target");
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
        _err("$target: failed to request $type issue #$issue_num");
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
          _err("$target: failed to update $type issue #$issue_num");
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
          _err("$target: failed to create $type issue");
      };

    my $msg = "- Created $type issue for $target";
    add_job_summary($msg);
}

sub close_issue (%opts)
{
    my ( $type, $issue_num, $comment, $target ) = @opts{ qw< type issue comment target > };

    print "$target: closing existing issue #$issue_num\n";

    my @cmd = (
        'gh',
        'issue',
        'close',
        $issue_num,
        '--repo',    $repo,
        '--comment', $comment,
    );

    system(@cmd) == 0
      or do {
          _err("$target: failed to close $type issue #$issue_num");
      };

    my $msg = "- Closed $type issue #$issue_num for $target";
    add_job_summary($msg);
}
