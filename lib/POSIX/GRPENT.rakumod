use v6;
use NativeCall;

class GrpEnt:ver<0.0.2>:auth<zef:sortiz> { ... }

my class GrStruct is repr<CStruct> {
    has Str         $!name;
    has Str         $!passwd;
    has uint32      $!gid;
    has CArray[Str] $!_mem;

    method members(::?CLASS:D:) {
	my $c = 0;
	do while $!_mem[$c] {
	    $!_mem[$c++]
	}
    }
    method Map(::?CLASS:D:) {
	Map.new: |(:$!name:$!passwd:$!gid :members(self.members));
    }
}

# actual NativeCall interfaces
sub _getgrnam(Str --> GrStruct) is native is symbol<getgrnam> {*}
sub _getgrgid(uint32 $gid --> GrStruct) is native is symbol<getgrgid> {*}
sub _getgrent(--> GrStruct) is native is symbol<getgrent> {*}
sub _setgrent() is native is symbol<setgrent> {*}
sub _endgrent() is native is symbol<endgrent> {*}

class GrpEnt {
    has Str	    $.name;
    has Str	    $.passwd;
    has Int	    $.gid:
    has Str	    @.members;
    method byname(GrpEnt:U: Str:D $name --> GrpEnt) {
	with _getgrnam($name) {
	    self.bless: |$_.Map
	} else { Nil }
    }
    method byuid(GrpEnt:U: Int:D $uid --> GrpEnt) {
	with _getgrgid($uid) {
	    self.bless: |$_.Map
	} else { Nil }
    }
    method Str(GrpEnt:D: --> Str) { $.name }
    method Numeric(GrpEnt:D: --> Int) { $.gid }
    method List(GrpEnt:D: --> List) {
	(for <name passwd gid members> {
	    $_ => self."$_"();
	});
    }
    method Map(GrpEnt:D: --> Map) { Map.new: |self.List }
    method Hash(GrpEnt:D: --> Hash) { % = |self.List }
}

class POSIX::GrpEntAcc:ver<0.0.2>:auth<zef:sortiz>
does Iterable does Positional does Associative {
    method of() { GrpEnt }
    multi method AT-POS(Int:D $uid) {
	GrpEnt.byuid($uid);
    }
    method EXISTS-POS(Int $uid) {
	GrpEnt.byuid($uid).Bool;
    }
    method AT-KEY(Str $name, *%h) {
	GrpEnt.byname($name);
    }
    method EXISTS-KEY(Str $name) {
	GrpEnt.byname($name).Bool;
    }
    method ASSIGN-KEY() {
	fail 'The group DB is read-only';
    }
    method iterator {
	class :: does Iterator {
	    method new() {
		_setgrent();
		self.bless();
	    }
	    method sink-all {
		_endgrent();
		IterationEnd;
	    }
	    method pull-one {
		with _getgrent() {
		    GrpEnt.new: |$_.Map;
		} else {
		    _endgrent();
		    IterationEnd;
		}
	    }
	}.new();
    }
}

Rakudo::Internals.REGISTER-DYNAMIC: '$*GRPENT', {
    PROCESS::<$GRPENT> := POSIX::GrpEntAcc.new
} unless PROCESS::<$GRPENT>;
