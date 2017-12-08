# TestExtra.jl
## Painless parallel testing.

[![Build Status](https://travis-ci.org/simonbyrne/TestExtra.jl.svg?branch=master)](https://travis-ci.org/simonbyrne/TestExtra.jl)

TestExtra.jl makes it easy to run multiple test files, and in parallel. Just create the following files containing

`test/REQUIRE`:
```
TestExtra
```

`test/runtests.jl`
```
using TestExtra
runtests()
```

This will run any other .jl files in the `test` directory, each in a separate process.

## TODO

* Nice output for
 - shell
 - travis
 - appveyor
 - circleci

* Line numbers should correspond to the error location!
 - https://github.com/JuliaLang/julia/issues/23987#issuecomment-334164560
 - provide a link, or excerpt?
