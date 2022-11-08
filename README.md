# POSIX::PWDENT
<center><h2>Prerelease</h2></center>

This module creates a few dynamic variables for easy access to information in the
`/etc/passwd` and `/etc/group` files in POSIX systems.

## Usage

```raku
need POSIX::PWDENT; # No "use" required as no exports available.

# To get the UID of user *auser* use `$*PWDENT` variable as an Associative
my $uid = +$*PWDENT<auser>;

# Or

my $uid = $*PWDENT<auser>.uid;

# To get tha name of the user with UID zero use the variable as Positional
say ~$*PWDENT[0];

# Or

say $*PWDENT[0].name;
```

## Reference

When you request the module to be loaded, the `$*PWDENT` dynamic variable is installed.

To get an entry by *name* use the variable as an `Associative` and to get an entry by *UID*
use the variable as a `Positional`.

Accessing `$*PWDENT` by any of the roles, if the entry exists, returns a `PwdEnt` object
with the following methods to access the corresponding fields of the entry:

- **name**
- **passwd**
- **uid**
- **gid**
- **gecos**
- **dir**
- **shell**

Similar to how Raku´s allomorphs works, evaluating the object in `Str` context returns the
value of `.name` and in `Numeric` context the value of `.uid`.

So, the fastest way to get get UID of a user named *auser* all you need to do is:

```raku
my $uid = +$*PWDENT<auser>; # Or $*PWDENT<auser>.Numeric
```

Or to get the user name with UID 123, you can:

```raku
my $user = ~$*PWDENT[123]; # Or $*PWDENT[123].Str
```

Even you can coerce the `PwdEnt` object to `IO` to get the value of `dir` as an `IO::Path`.

Requesting an inexistent entry returns an undefined value. As with other positional or
associative you can use the `:exists` adverb to check existence.

```raku
say $*PWDENT<root>:exists; # True (root user almost always exists)

say $*PWDENT[0]:exists; # True

if $*PWDENT<postgres>:exists {
    # The user postgres exists
    …
}
```

The `$*PWDENT` variable can also be used as an `Iterable`, so to get a list of the user
names available in the system you can:

```raku
my @users is List = (~$_ for $*PWDENT);
```

### Caveat

The `PwdEnt` object returned references the **static** C struct returned by low-level system
calls and it is modified by any new query or at each iteration step. So you SHOULD NOT attempt
to preserve it for long-term use:

```raku
# This doesn't work:
my $foouser = $*PWDENT<foo>; # $foouser is a PwdEnt object
my $baruser = $*PWDENT<bar>; # This invalidate $foouser contents!!
```

The values returned by its methods are standard Str or Int values, however.

### Convert PwdEnt object to other types

If you need to keep the returned data for long-term use, you can coerce it to
`Map`, `Hash` or `List` objects (whose keys will be the names of the methods above):

```raku
# This works as expected
my $foouser = $*PWDENT<foo>.Map; # $foouser is a standard inmutable raku Map
my $baruser = $*PWDENT<bar>.Map;
…
# You can use any of $foouser or $baruser
```

When you the need it, you can use the `@*PWDENT` dynamic variable as an stable `Iterable`,
as it returns the `Map` versions:

```raku
for @*PWDENT {
    # Here $_ is an standard Map
}
```

## Author

Salvador Ortiz

