use v6;
use NativeCall;

class GrpEnt:ver<0.0.1>:auth<zef:sortiz> is repr('CStruct') { ... }
sub getgrnam(Str:D $name --> GrpEnt) is native { * };
sub getgrgid(int32 $uid --> GrpEnt) is native { * };
sub getgrent(--> GrpEnt) is native(Str) { * };
sub setgrent() is native { * };
sub endgrent() is native { * };
class GrpEnt {
    has Str	$.name is readonly;
    has Str	$.passwd is readonly;
    has uint32	$.gid is readonly;
    has Pointer	$._mem is readonly;
    method byname(GrpEnt:U: Str:D $name --> GrpEnt) {
	getgrnam($name);
    }
    method byuid(GrpEnt:U: Int:D $uid --> GrpEnt) {
	getgrgid($uid);
    }
    method Str(GrpEnt:D: --> Str) { $.name }
    method Numeric(GrpEnt:D: --> Int) { $.gid }
    method List(GrpEnt:D: --> List) {
	(for <name passwd gid> {
	    $_ => self."$_"();
	});
    }
    method Map(GrpEnt:D: --> Map) { Map.new: |self.List }
    method Hash(GrpEnt:D: --> Hash) { % = |self.List }
}

class POSIX::GrpEntAcc:ver<0.0.1>:auth<zef:sortiz>
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
		setgrent();
		self.bless();
	    }
	    method sink-all {
		endgrent();
		IterationEnd;
	    }
	    method pull-one {
		with getgrent() {
		    $_;
		} else {
		    endgrent();
		    IterationEnd;
		}
	    }
	}.new();
    }
    method vI {
	class :: does Iterable does Iterator {
	    method iterator { self }
	    method new() {
		setgrent();
		self.bless();
	    }
	    method sink-all {
		endgrent();
		IterationEnd;
	    }
	    method pull-one {
		with getgrent() {
		    $_.Map;
		} else {
		    endgrent();
		    IterationEnd;
		}
	    }
	}.new();
    }
}

Rakudo::Internals.REGISTER-DYNAMIC: '$*GRPENT', {
    PROCESS::<$GRPENT> := POSIX::GrpEntAcc.new;
}
Rakudo::Internals.REGISTER-DYNAMIC: '@*GRPENT', {
    PROCESS::<@GRPENT> := POSIX::GrpEntAcc.new.vI;
}
