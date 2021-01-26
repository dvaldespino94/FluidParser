import std.stdio;
import std.format;
import std.algorithm.searching;
import std.algorithm.iteration;
import std.file;
import std.array;
import std.range;
import std.string;

import statemachine;
import types;

void main(string[] args)
{
    if (args.length < 2)
    {
        writeln("Wrong param count!");
        return;
    }

    string fname = args[1];
    if (!exists(fname))
    {
        writefln("File %s doesn't exists!", fname);
        return;
    }

    string data = readText(fname);

    auto m = new StateMachine(data);

    string dump = `import fltk_d;
import core.stdc.stdint;

`;
    foreach (node; m.Nodes)
    {
        dump ~= node.generate;
    }
    //foreach (wclass; WidgetClass.all)
    //{
    //dump ~= wclass.generate ~ "\n";
    //}

    std.file.write("test.d", dump);
}
