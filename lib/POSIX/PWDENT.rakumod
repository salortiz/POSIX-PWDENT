use v6;
use NativeCall;

class PwdEnt:ver<0.0.1>:auth<zef:sortiz> is repr('CStruct') { ... }
sub getpwnam(Str:D $name --> PwdEnt) is native { * };
sub getpwuid(int32 $uid --> PwdEnt) is native { * };
sub getpwent(--> PwdEnt) is native(Str) { * };
sub setpwent() is native { * };
sub endpwent() is native { * };
class PwdEnt {
    has Str	$.name is readonly;
    has Str	$.passwd is readonly;
    has uint32	$.uid is readonly;
    has uint32	$.gid is readonly;
    has Str	$.gecos is readonly;
    has Str	$.dir is readonly;
    has Str	$.shell is readonly;
    method byname(PwdEnt:U: Str:D $name --> PwdEnt) {
	getpwnam($name);
    }
    method byuid(PwdEnt:U: Int:D $uid --> PwdEnt) {
	getpwuid($uid);
    }
    method Str(PwdEnt:D: --> Str) { $.name }
    method Numeric(PwdEnt:D: --> Int) { $.uid }
    method IO(PwdEnt:D: --> IO::Path) { $.dir.IO }
    method List(PwdEnt:D: --> List) {
	(for <name passwd uid gid gecos dir shell> {
	    $_ => self."$_"();
	});
    }
    method Map(PwdEnt:D: --> Map) { Map.new: |self.List }
    method Hash(PwdEnt:D: --> Hash) { % = |self.List }
}

class POSIX::PwdEntAcc:ver<0.0.1>:auth<zef:sortiz> does Iterable does Positional does Associative {
    method of() { PwdEnt }
    multi method AT-POS(Int:D $uid) {
	PwdEnt.byuid($uid);
    }
    method EXISTS-POS(Int $uid) {
	PwdEnt.byuid($uid).Bool;
    }
    method AT-KEY(Str $name, *%h) {
	PwdEnt.byname($name);
    }
    method EXISTS-KEY(Str $name) {
	PwdEnt.byname($name).Bool;
    }
    method ASSIGN-KEY() {
	fail 'The password DB is read-only';
    }
    method iterator {
	class :: does Iterator {
	    method new() {
		setpwent();
		self.bless();
	    }
	    method sink-all {
		endpwent();
		IterationEnd;
	    }
	    method pull-one {
		with getpwent() {
		    $_;
		} else {
		    endpwent();
		    IterationEnd;
		}
	    }
	}.new();
    }
    method vI {
	class :: does Iterable does Iterator {
	    method iterator { self }
	    method new() {
		setpwent();
		self.bless();
	    }
	    method sink-all {
		endpwent();
		IterationEnd;
	    }
	    method pull-one {
		with getpwent() {
		    $_.Map;
		} else {
		    endpwent();
		    IterationEnd;
		}
	    }
	}.new();
    }
}

Rakudo::Internals.REGISTER-DYNAMIC: '$*PWDENT', {
    PROCESS::<$PWDENT> := POSIX::PwdEntAcc.new;
}
Rakudo::Internals.REGISTER-DYNAMIC: '@*PWDENT', {
    PROCESS::<@PWDENT> := POSIX::PwdEntAcc.new.vI;
}
