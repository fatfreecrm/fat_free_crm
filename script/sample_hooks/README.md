# Sample Git Hooks

This directory contains sample git hooks. To use them, copy them to the `.git/hooks` directory in your local repository.

## Pre-commit

This hook runs `rubocop` on all staged `.rb` files and `erblint` on all staged `.js` files. If either of these linters fail, the commit will be aborted.

## Pre-push

This hook runs `rspec`. If the test suite fails, the push will be aborted.
