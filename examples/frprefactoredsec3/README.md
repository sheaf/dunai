# Installation

```
cabal sandbox init
cabal install
cabal repl
```

# Examples to run in cabal repl

Examples that work:

```
embed (add 7) [1, 2, 3]
embed (second (add 7)) [(1, 1), (2, 2), (3, 3)]
```
Example that does not work:

```
embed testSerial (repeat 1 ())
```

Error message:

```
    • Couldn't match expected type ‘() -> [()]’
                  with actual type ‘[Integer]’
    • The function ‘repeat’ is applied to two arguments,
      but its type ‘Integer -> [Integer]’ has only one
      In the second argument of ‘embed’, namely ‘(repeat 1 ())’
      In the expression: embed testSerial (repeat 1 ())
```

