# Installation

```
cabal sandbox init
cabal install
cabal repl
```

# Examples of Section 3 to run in cabal repl

```
embed (add 7) [1, 2, 3]
embed (second (add 7)) [(1, 1), (2, 2), (3, 3)]
-- The paper says 'repeat', but it is 'replicate' (see #163).
embed testSerial (replicate 1 ())
-- Type 'Text' and hit return.
```
