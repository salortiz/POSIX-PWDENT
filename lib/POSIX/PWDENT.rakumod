use v6;
use NativeCall;

class PwdEnt:ver<0.0.2>:auth<zef:sortiz> { ... }

my class PwStructBSD is repr<CStruct> {  # BSD's  appears to have their own
    has Str    $.name;
    has Str    $.passwd;
    has uint32 $.uid;
    has uint32 $.gid;
    has long   $.change;
    has Str    $.class;
    has Str    $.gecos;
    has Str    $.dir;
    has Str    $.shell;
    has long   $.expire;
    has int32  $.fields;

    method Map(::?CLASS:D:) {
	Map.new: | do
	    for ::?CLASS.^attributes>>.name>>.subst('$!') {
		$_ => self."$_"()
	    };
    }
}

my class PwStructLinux is repr<CStruct> {   # as has Linux
    has Str    $.name;
    has Str    $.passwd;
    has uint32 $.uid;
    has uint32 $.gid;
    has Str    $.gecos;
    has Str    $.dir;
    has Str    $.shell;

    method Map(::?CLASS:D:) {
	Map.new: | do
	    for ::?CLASS.^attributes>>.name>>.subst('$!') {
		$_ => self."$_"()
	    }
    }
}

my class PwStructUnix is repr<CStruct> {
    has Str    $.name;
    has Str    $.passwd;
    has uint32 $.uid;
    has uint32 $.gid;
    has Str    $.dir;
    has Str    $.shell;

    method Map(::?CLASS:D:) {
	Map.new: |(for <name passwd uid gid dir shell> {
	    $_ => self."$_"()
	});
    }
}

my constant PwStruct =
  $*KERNEL.name eq 'darwin' | 'freebsd'
    ?? PwStructBSD
    !! $*KERNEL.name eq 'linux'
      ?? PwStructLinux
      !! PwStructUnix;

# actual NativeCall interfaces
sub _getpwnam(Str --> PwStruct) is native is symbol<getpwnam> {*}
sub _getpwuid(uint32 $uid --> PwStruct) is native is symbol<getpwuid> {*}
sub _getpwent(--> PwStruct) is native is symbol<getpwent> {*}
sub _setpwent() is native is symbol<setpwent> {*}
sub _endpwent() is native is symbol<endpwent> {*}

class PwdEnt {
    has Str	$.name;
    has Str	$.passwd;
    has Int	$.uid;
    has Int	$.gid;
    has Int    $.change = 0;
    has Str     $.class = '';
    has Str	$.gecos = '';
    has Str	$.dir;
    has Str	$.shell;
    has Int	$.expire = 0;
    has Int	$.fields = 0;
    method byname(::?CLASS:U: Str:D $name --> ::?CLASS) {
	with _getpwnam($name) {
	    self.bless: |$_.Map;
	}
	else { Nil }
    }
    method byuid(::?CLASS:U: Int:D $uid --> ::?CLASS) {
	with _getpwuid($uid) {
	    self.bless: |$_.Map
	}
        else { Nil }
    }
    method Str(::?CLASS:D: --> Str) { $.name }
    method Numeric(::?CLASS:D: --> Int) { $.uid }
    method IO(::?CLASS:D: --> IO::Path) { $.dir.IO }
    method List(::?CLASS:D: --> List) {
	(for ::?CLASS.^attributes>>.name>>.subst('$!') {
	    $_ => self."$_"();
	});
    }
    method Map(::?CLASS:D: --> Map) { Map.new: |self.List }
    method Hash(::?CLASS:D: --> Hash) { % = |self.List }
}

class POSIX::PwdEntAcc:ver<0.0.2>:auth<zef:sortiz>
does Iterable does Positional does Associative {
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
		_setpwent();
		self.bless();
	    }
	    method sink-all {
		_endpwent();
		IterationEnd;
	    }
	    method pull-one {
		with _getpwent() {
		    PwdEnt.new: |$_.Map;
		} else {
		    _endpwent();
		    IterationEnd;
		}
	    }
	}.new();
    }
}

Rakudo::Internals.REGISTER-DYNAMIC: '$*PWDENT', {
    PROCESS::<$PWDENT> := POSIX::PwdEntAcc.new;
}
