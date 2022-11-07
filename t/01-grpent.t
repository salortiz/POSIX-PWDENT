use v6;
use Test;

plan 29;

need POSIX::GRPENT;

my \GrpEntAcc = ::('POSIX::GrpEntAcc');

ok $*GRPENT !~~ Failure,        'Dynamic $*GRPENT installed';
isa-ok $*GRPENT, GrpEntAcc;
does-ok $*GRPENT, Positional;
does-ok $*GRPENT, Associative;
does-ok $*GRPENT, Iterable;

# Test by known user
my $root = $*GRPENT[0];
ok $root,			"Group 'root' exists";
isa-ok $root, GrpEnt;
given $root {
    is .gid, 0,			'Its gid is zero';
    is +$_, 0,			'As Numeric is zero';
    is .name, 'root',		'Name check';
    is ~$_, 'root',		'As Str is root';
    is .gid, 0,			'root gid is zero';
    #ok $_ eqv $*GRPENT<root>,	'The same by name';
}
my $sroot = $root.Map;

# Check current user
note "Testing with group $*GROUP";
ok my $group = $*GRPENT{$*GROUP}, 'Cat get current user´s group';
with $group {
    ok .name eq $*GROUP,        'same name';
    ok .passwd.defined,		'Group has a passwd';
    ok .gid.defined,		"user has gid ({.gid})";
    ok .gid == $*GROUP,		'gid';
}
my $sgroup = $group.Map;

# Test some cohercions
ok $group.List ~~ List,		'Can convert to List';
ok $group.Map ~~ Map,		'Can convert to Map';
ok $group.Hash ~~ Hash,		'Can convert to Hash';

# Test some nouser
without $*GRPENT<NoSuChUser> {
    pass			'No such user';
    ok $_ ~~ GrpEnt,		'Correct type';
    nok .defined,		'Undefined';
    nok .DEFINITE,		'Not an instance';
}

ok @*GRPENT ~~ Iterable,	'Dynamic @*GRPENT installed';
ok (my @grdb is List = @*GRPENT) ~~ List, 'So can get an stable List';
ok @grdb.elems > 1,		"Current pwddb has {@grdb.elems} entries";
ok @grdb.first({$_<name> eq 'root'}) eqv $sroot, 'root in there';
ok @grdb.first({$_<name> eq $*GROUP}) eqv $sgroup, 'user in there';
