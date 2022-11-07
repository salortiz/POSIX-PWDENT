# POSIX::PWDENT

This module creates a few dynamic variables for easy access to information in the
`/etc/passwd` and `/etc/group` files in POSIX systems.

## Usage

```raku
need POSIX::PWDENT;

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

When your  request the module to be loaded, the `$*PWDENT` dynamic variable is installed.

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
my $uid = +$*PWDENT<auser>;
```

Or to get the user name with UID 123, you can:

```raku
my $user = ~$*PWDENT[123];
```

Requesting an inexistent entry returns an undefined value. As with other positional or
associative you can use the `:exists` adverb to check existence.


## Author

Salvador Ortiz

