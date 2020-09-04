# emacs-ocamlunit

This is a Emacs minor mode implementation for to run OUnit2 tests or other tests in a OCaml `dune` project.

Tests are actually run with `dune test`. So also other test definitions than OUnit/OUnit2 are run also.

There is no package on Elpa or Melpa.
To install it clone this to some local folder and initialize like this in Emacs:

```
(use-package ocamlunit
  :load-path "~/.emacs.d/plugins/ocamlunit")
```

When done you have a minor mode called `ocamlunit-mode`.

This mode can be enabled for basically every buffer but only `tuareg-mode` buffers are supported.
On other code or project it just saves the buffer.

To run the tests a buffer use the key sequence: `C-c t`.
This will first save the buffer and then run the tests using `dune`.

After the first execution of `ocamlunit-execute` you can view the "OCamlUnit output" buffer for test output.
