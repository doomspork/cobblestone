# Cobblestone Modernization & jq Feature Parity Report

## Current Capabilities

Cobblestone currently implements a subset of JSONPath/XPath functionality:

  - Basic path navigation (.store.book)
  - Recursive descent (..author)
  - Array indexing ([0], [0,2,3], [-1])
  - Array slicing ([1:3], [:2], [2:])
  - Simple filtering ([isbn] for existence, [price>20] for comparison)
  - Leex/Yecc parser for path expressions

## Missing jq Features (Priority Order)

  ### 🔴 High Priority - Core Functionality

    1. ✅ Pipe operator (|) - Chain operations together - COMPLETED
    2. ✅ Identity filter (.) - Return entire structure - COMPLETED
    3. ✅ Array/Object iterator ([]) - Iterate without key - COMPLETED
    4. ✅ select() function - More complex filtering - COMPLETED
    5. ✅ map() function - Transform arrays - COMPLETED
    6. Object construction ({key: .value})
    7. Array construction ([.field1, .field2])

  ### 🟡 Medium Priority - Essential Operations

    8. Arithmetic operators (+, -, *, /, %)
    9. Logical operators (and, or, not)
    10. Alternative operator (//) - Default values
    11. keys function - Get object keys
    12. length function - Array/object/string length
    13. Type functions (type, has())
    14. String functions (split, join, test)
    15. sort_by() and group_by()

  ### 🟢 Low Priority - Advanced Features

    16. Conditionals (if-then-else)
    17. try-catch error handling
    18. to_entries/from_entries
    19. Recursive operations (recurse, ..)
    20. Math functions (min, max, add)
    21. Date functions
    22. String interpolation
    23. Variable assignment (as $var)
    24. Custom functions (def)

## Modernization Opportunities

  1. ✅ Fix Compiler Warnings - COMPLETED

  # mix.exs needs:
  compilers: [:leex, :yecc] ++ Mix.compilers()

  2. Enhanced Error Handling

  - Return structured errors instead of parser crashes
  - Add helpful error messages with path location

  3. Performance Optimizations

  - Stream processing for large datasets
  - Lazy evaluation where possible
  - Compiled query caching

  4. Better Elixir Integration

  - Support atoms as keys (not just strings)
  - Pipeline-friendly API
  - Protocol implementations for custom types

  5. Testing & Documentation

  - Property-based testing with StreamData
  - Comprehensive doctest examples
  - Performance benchmarks

  Recommended Implementation Roadmap

  Phase 1: Foundation (Week 1-2)
  - Fix compiler warnings
  - Add pipe operator support
  - Implement identity filter
  - Add select() function
  - Improve error handling

  Phase 2: Core Features (Week 3-4)
  - Object/array construction
  - map() function
  - Arithmetic operators
  - keys and length functions

  Phase 3: Advanced (Week 5-6)
  - Conditionals
  - Variable assignment
  - String operations
  - Sort/group functions

  This would bring Cobblestone much closer to jq's capabilities while maintaining its Elixir-native advantages.