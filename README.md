# FluidParser
Fluid Interface Definition Language parser and D code generator.

# Implemented so far:
- Comments
- Decls
- Widget Classes
    + Childs (Recursive, with their properties)
- Properties(box, align, label, colors ...)
- Function scaffolds: **WARNING**: WRITES DIRECTLY THE CODE(C++ or whatever) TO THE D OUTPUT FILE

# Limits:
- I don't plan to support C/C++ code convertion to D, so it's only supposed for scaffolding
- I don't think that creating the widgets from fluid functions is a good approach, so (for now) I won't support that, so: **ONLY** ClassWidgets will be supported(**UNLESS**) someone asks me for that feature.
- I havent yet ported the WHOLE FLTK library to D, so, some classes are not available when compiling, but the parser _should_ work OK.
- New lines and spaces(tabs too) are lost in parsing
