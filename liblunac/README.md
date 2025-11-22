# Luna Compiler
## Dependencies
* libLLVM - LLVM version 20
## Pipeline
 1. Lexer
 2. Parser
 4. Name resolution
 7. Type and trait checker
 8. Auto-trait insertion
 9. Lifetime checker
 5. Constant folding (1st round)
10. End-of-scope destructor insertion
11. Monomorphization (generic type expansion)
12. Lower to Luna Intermediate Representation (LIR)
14. LIR Optimizer
15. Lower to LLVMIR
16. LLVM black box