# objc-diff

![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat) [![Build Status](https://travis-ci.org/dreampiggy/objc-diff.svg?branch=master)](https://travis-ci.org/dreampiggy/objc-diff) 

Generates a text, XML, or HTML report of the API differences between two versions of an Objective-C library. It assists library authors with creating a diff report for their users and verifying that no unexpected API changes have been made.

## Status

Beta. The tool has been tested against the system frameworks and a number of third-party libraries, but I'd like to open it to feedback and additional testing before considering the command line interface and XML format stable.

## Install

+ Using [Homebrew](https://brew.sh/)

```
brew tap dreampiggy/homebrew-taps
brew install objc-diff
```

+ Manual

1. Download [the latest release](https://github.com/dreampiggy/objc-diff/releases)
2. Unzip the `objc-diff.zip`
3. Move the `objc-diff` and `ObjectDoc.framework` into your `PATH` (Such as `/usr/local/bin/`)

## Usage

    objc-diff [--old <path to old API>] --new <path to new API> [options]

    API paths may be specified as a path to a framework, a path to a single
    header, or a path to a directory of headers.

    Options:
      --help             Show this help message and exit
      --title            Title of the generated report
      --text             Write a text report to standard output (the default)
      --xml              Write an XML report to standard output
      --html <directory> Write an HTML report to the specified directory
      --sdk <name>       Use the specified SDK
      --old <path>       Path to the old API
      --new <path>       Path to the new API
      --args <args>      Compiler arguments for both API versions
      --oldargs <args>   Compiler arguments for the old API version
      --newargs <args>   Compiler arguments for the new API version
      --semversion       Analysis the sem-version changes base on diff changes for API
      --skip-error       Skip any parser error from clang and try to generate report
      --version          Show the version and exit

See the [man page](OCDiff/objc-diff.pod) for expanded usage information.

## Author

- landonf (Original Author)
- DreamPiggy

