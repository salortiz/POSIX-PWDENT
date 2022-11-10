# POSIX::PWDENT

This module creates two new dynamic variables for easy access to information in the
`/etc/passwd` and `/etc/group` files in POSIX systems.

## Usage

To query data in `/etc/passwd` use the $*PWDENT variable:

```raku
need POSIX::PWDENT; # No "use" required as no exports available.

# To get the UID of user named 'auser' use $*PWDENT variable as an Associative
my $uid = $*PWDENT<auser>.uid;
# Or
my $uid = +$*PWDENT<auser>;

# To get the name of the user with UID zero use the variable as a Positional
say $*PWDENT[0].name;
# Or
say ~$*PWDENT[0];
```

To query data in `/etc/group` use the $*GRPENT variable

```raku
need POSIX::GRPENT; # No "use" required as no exports available.

# To get the GID of a gruop named 'agroup' use $*GRPENT variable as an Associative
my $gid = $*PWDENT<auser>.gid;
# Or
my $gid = +$*PWDENT<agroup>;

# To get the name of the group with GID zero use the variable as a Positional
say $*GRPENT[0].name;
# Or
say ~$*GRPENT[0];

```

## Reference
### The $*PWDENT dynamic variable

When you request the POSIX::PWDENT module to be loaded, the `$*PWDENT` dynamic variable
is installed.

To get an entry by *name* use the variable as an `Associative` and to get an entry by *UID*
use the variable as a `Positional`.

Accessing `$*PWDENT` by any of the roles, if the entry exists, returns a `PwdEnt` object
with the following methods to access the corresponding fields of the entry:

- **name**      Str
- **passwd**    Str
- **uid**       Int
- **gid**       Int
- **change**    Int     Valid only in BSD and Darwin, 0 otherwise
- **class**     Str     Valid only in BSD and Darwin, '' otherwise
- **gecos**     Str     Valid only in Linux, BSD and Darwin, '' otherwise
- **dir**       Str
- **shell**     Str
- **expire**    Int     Valid only in BSD and Darwin, 0 otherwise
- **fields**    Int     Valid only in BSD and Darwin, 0 otherwise

Similar to how Raku´s allomorphs works, evaluating a `PwdEnt` object in `Str` context returns the
value of `.name` and in `Numeric` context the value of `.uid`.

So to get the user name with UID 123, you can:

```raku
my $uname = ~$*PWDENT[123]; # Or $*PWDENT[123].Str
```

Or to get the UID of a user named *auser* all you need to do is:

```raku
my $uid = +$*PWDENT<auser>; # Or $*PWDENT<auser>.Numeric
```

Even you can coerce the `PwdEnt` object to `IO` to get the value of `dir` as an `IO::Path`.

The `$*PWDENT` variable can also be used as an `Iterable`, so to get a list of the user
names available in the system you can:

```raku
my @users is List = (~$_ for $*PWDENT);
```

### The $*GRPENT dynamic variable

When you request the POSIS::GRPENT module to be loaded, the $*GRPENT dynamic variable
is installed

To get an entry by *name* use the variable as an `Associative` and to get an entry by *GID*
use the variable as a `Positional`.

Accessing `$*GRPENT` by any of the roles, if the entry exists, returns a `GrpEnt` object
with the following methods to access the corresponding fields of the entry:

- **name**      Str
- **passwd**    Str
- **gid**       Int
- **members**   List of Str

Similar to how Raku´s allomorphs works, evaluating a `GrpEnt` object in `Str` context returns the
value of `.name` and in `Numeric` context the value of `.gid`.

So, to get the group name with GID 123, you can:

```raku
my $uname = ~$*GRPENT[123]; # Or $*GRPENT[123].Str
```

Or to get the GID of a group named *agroup* all you need to do is:

```raku
my $gid = +$*GRPENT<auser>; # Or $*GRPENT<auser>.Numeric
```

The `$*GRPENT` variable can also be used as an `Iterable`, so to get a list of all group
names available in the system you can:

```raku
my @group is List = (~$_ for $*GRPENT);
```

### Non existing entries

Requesting an inexistent entry from any of `$*PWDENT` or `$*GRPENT` returns `Nil`.
So, you can use `with`

```raku
with $*PWDENT<apache> {
   # User 'apache' exists, can access its methods
   say .gecos;
   say "Apache dir is {.dir}";
}

with $*GRPENT<wheel> {
   # User 'wheel' exists, can access its methods
   say .members; # The list of users with access to 'sudo' in (some?) Linux
}
```

As with other positional or associative you can use the `:exists` adverb to check existence.

```raku
say $*PWDENT<root>:exists; # True (root user almost always exists)

say $*PWDENT[0]:exists; # True

if $*GRPENT<kvm>:exists {
    # The group 'kvm' exists
    …
}
```

### Convert PwdEnt or GRPENT objects to other types

If you need to access the returned data as other kind of structure, you can coerce it to
`Map`, `Hash` or `List` objects (whose keys will be the names of the methods above):

```raku
my $foouser = $*PWDENT<foo>.Map;
say $foouser<name>; # Use name as a key, not as a method

my $bargroup = $*GRPENT<bar>.List;
```

## Author

Salvador Ortiz <sortiz@cpan.org>

