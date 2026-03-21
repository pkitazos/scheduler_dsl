# Scheduler

Under construction...

Converts natural language scheduling instructions to cron

## Architecture

The codebase follows a classic compiler pipeline: **Lexer -> Parser -> AST**

1. **Input**: Natural language schedule string (e.g., "every 30 minutes on weekdays")
2. **Lexer** ([src/library/lexer.gleam](src/library/lexer.gleam)): Tokenizes the input string into a list of tokens
3. **Parser** ([src/library/parser.gleam](src/library/parser.gleam)): Converts tokens into an AST
4. **AST** ([src/library/ast.gleam](src/library/ast.gleam)): Structured representation of the schedule
