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

## License

See the file `COPYING` in this directory.
