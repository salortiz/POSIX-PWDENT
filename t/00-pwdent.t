use v6;
use Test;

plan 34;

need POSIX::PWDENT;

my \PwdEntAcc = ::('POSIX::PwdEntAcc');

ok $*PWDENT !~~ Failure,        'Dynamic $*PWDENT installed';
isa-ok $*PWDENT, PwdEntAcc;
does-ok $*PWDENT, Positional;
does-ok $*PWDENT, Associative;
does-ok $*PWDENT, Iterable;

# Test by known user
my $root = $*PWDENT[0];
ok $root,			"User 'root' exists";
isa-ok $root, PwdEnt;
given $root {
    is .uid, 0,			'Its uid is zero';
    is +$_, 0,			'As Numeric is zero';
    is .name, 'root',		'root is root';
    is ~$_, 'root',		'As Str is root';
    is .gid, 0,			'root gid is zero';
    ok $_ eqv $*PWDENT<root>,	'The same by name';
    ok IO($_) ~~ IO::Path,	'As IO is IO::Path';
}
my $sroot = $root.Map;

# Check current user
note "Testing with user $*USER";
ok my $user = $*PWDENT{$*USER}, 'Cat get current user';
with $user {
    ok .name eq $*USER,	        'same name';
    ok .passwd,			'user has a passwd';
    ok .uid.defined,		"user has uid ({.uid})";
    ok .gid.defined,		"user has uid ({.gid})";
    ok .dir,			"user has dir ({.dir})";
    ok .gecos.defined,		"user has gecos ({.gecos})";
    ok .shell.defined,		"user has a shell ({.shell})";
}
my $suser = $user.Map;

# Test some cohercions
ok $user.List ~~ List,		'Can convert to List';
ok $user.Map ~~ Map,		'Can convert to Map';
ok $user.Hash ~~ Hash,		'Can convert to Hash';

# Test some nouser
without $*PWDENT<NoSuChUser> {
    pass			'No such user';
    ok $_ ~~ PwdEnt,		'Correct type';
    nok .defined,		'Undefined';
    nok .DEFINITE,		'Not an instance';
}

ok @*PWDENT ~~ Iterable,	'Dynamic @*PWDENT installed';
ok (my @pwdb is List = @*PWDENT) ~~ List, 'So can get an stable List';
ok @pwdb.elems > 1,		"Current pwddb has {@pwdb.elems} entries";
ok @pwdb.first({$_<name> eq 'root'}) eqv $sroot, 'root in there';
ok @pwdb.first({$_<name> eq $*USER}) eqv $suser, 'user in there';
