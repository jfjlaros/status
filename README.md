# Status scripts for i3blocks
Various status monitoring scrips using a common library.

## Installation
Make sure to install [Font Awesome](http://fontawesome.io/) for the icons to
render correctly.

Get the repository (as root) and install it in the i3blocks directory.

    git clone git://github.com/jfjlaros/status.git /usr/share/i3blocks/status

To configure your i3blocks behaviour, edit `~/.config/i3blocks/config`. Please
have a look at this [sample configuration file](i3blocks_config.sample).

## API
To use the library, simply source the library file from your script.

```bash
. "/usr/share/i3blocks/status/lib/status.bash"
```

This imports three functions: `scale`, `pick_colour`, `pick_icon` and a wrapper
function `format_info`.

The `scale` function is used to convert a value, given a minimum and a maximum,
to a percentage. For example, to convert the value 120 in the range 40 to 1000,
to a percentage:

```bash
$ scale 120 40 1000
8
```

The `pick_colour` function is used to convert a percentage to an RGB value
ranging from green to red. For example:

```bash
$ pick_colour 35
#b2ff00
```

The `pick_icon` function is used to convert a percentage to an icon. For
example:

```bash
$ pick_icon 21 ABCDE
B
```

Finally, the wrapper function named `format_info` will pick a colour and an
icon based on a value and it will echo some additional info back. For simple
status scripts, this function is probably all that is needed. A simple example
will look like this:

```bash
$ format_info ABCDE 21 "status text"
B status text

#6bff00
```

This function also accepts the following optional arguments:

- `invert` (default false) inverts the colour.
- `minimum` (default 0) and `maximum` (default 100) for converting to a
  percentage.

A more complicated example, where we want to show a value between 10 and 30 and
we want the colour to go from red to green:

```bash
$ format_info ABCDE 21 "status text" true 10 30
C status text

#e5ff00
```
