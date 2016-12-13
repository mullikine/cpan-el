# cpan.el README

The CPAN shell is just another shell, so why not drive it from Emacs?

`cpan.el` is a simple shell mode that does just that.

## Install

```
(add-to-list 'load-path (expand-file-name "/path/to/cpan-el/"))
(setf cpan-file-name "cpan")

(require 'cpan)
```

## Run

Start it with `M-x cpan`.

## About

This code is a modified version of the built-in `shell.el`.  There is
probably more work needed to get this up to snuff (completion? syntax
highlighting?), but it works.  It even "works" on Windows (modulo bugs
in the way the prompt is displayed, for reasons that are unclear to
me).

## License

See the file `COPYING` in this directory.  Since it's a modified
version of `shell.el`, we use GPLv3.
