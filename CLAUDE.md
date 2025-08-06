# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cobblestone is an Elixir library for querying and transforming data structures, inspired by jq, JSONPath, and XPath. It provides a path-based query language for navigating and filtering nested maps and lists.

## Development Commands

### Build and Compile
```bash
# Compile the project (generates parser files from .xrl and .yrl)
mix compile

# Compile with warnings as errors
mix compile --warnings-as-errors
```

Note: The project has compiler warnings about missing `:leex` and `:yecc` compilers in mix.exs that should be fixed by adding `compilers: [:leex, :yecc] ++ Mix.compilers()` to the project definition.

### Testing
```bash
# Run all tests
mix test

# Run tests with verbose output
mix test --trace

# Run a specific test file
mix test test/cobblestone_test.exs

# Run a specific test by line number
mix test test/cobblestone_test.exs:42
```

### Dependencies
```bash
# Get dependencies
mix deps.get

# Update dependencies
mix deps.update --all
```

## Architecture

### Parser Pipeline
The system uses a three-stage pipeline for processing query paths:

1. **Lexer (src/cs_lexer.xrl)**: Tokenizes the input string into meaningful tokens (vars, ints, operators, brackets, dots). Uses Erlang's leex.

2. **Parser (src/cs_parser.yrl)**: Parses tokens into an AST representing the query structure. Uses Erlang's yecc for grammar-based parsing. Key productions:
   - Path navigation: `.key`, `..key` (recursive)
   - Array operations: `[index]`, `[start:end]`, `[index1,index2]`
   - Filters: `[key]`, `[key>value]`, `[key<value]`

3. **Path Walker (lib/path.ex)**: Executes the parsed AST against the data structure. Implements:
   - Local navigation (single level)
   - Global/recursive search (all matching keys)
   - Array slicing and indexing (including negative indices)
   - Filter predicates

### Core API
- **Cobblestone.get_at_path/2**: Main entry point that coordinates the pipeline
- **Cobblestone.Parser.parse/1**: Handles lexing and parsing
- **Cobblestone.Path.walk/2**: Executes the query against data

### Query Language Features
Currently supports:
- Direct path access: `.store.book`
- Recursive descent: `..author`
- Array indexing: `[0]`, `[-1]` (negative indices)
- Array slicing: `[1:3]`, `[:2]`, `[2:]`
- Multiple indices: `[0,2,3]`
- Existence filters: `[isbn]`
- Comparison filters: `[price>20]`, `[price<10]`

### Testing Approach
Tests use a sample bookstore data structure (see @sample in test file) to verify all query operations. Each feature has dedicated test cases demonstrating expected behavior.