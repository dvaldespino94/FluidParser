# FluidParser
Fluid Interface Definition Language parser and D code generator.

# Implemented so far:
- Comments
- Decls
- Widget Classes
    + Childs (Recursive, with their properties)
- Properties(box, align, label, colors ...)

# Limits:
- I don't plan to support C/C++ code convertion to D, so it's only supposed for scaffolding
- I havent yet ported the WHOLE FLTK library to D, so, some classes are not available when compiling, but the parser _should_ work OK.