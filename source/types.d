import std.stdio;
import std.format;
import std.algorithm.searching;
import std.algorithm.iteration;
import std.file;
import std.array;
import std.range;
import std.string;
import std.conv;

import consts;
import statemachine;

class Property
{
    string Name;
    string Value = null;

    this(StateMachine m)
    {
        this.Name = m.Word;
        //Skip the name
        m.Ptr++;

        if (!isFlag)
        {
            //This auto skips the string, so there is no Ptr++ here
            this.Value = m.readString;
        }
    }

    bool isFlag()
    {
        return FlagProperties.canFind(this.Name);
    }

    override string toString()
    {
        return isFlag ? "[%s]".format(this.Name) : "[%s=%s]".format(this.Name, this.Value);
    }
}

class WidgetNode:Node
{
    static WidgetNode[] all;
    string Name;

    Property[] Properties;
    Widget[] Widgets;
    StateMachine M;

    this(StateMachine m)
    {
        all ~= this;

        this.M = m;
        this.Name = m.readString();
        //writefln("=> WidgetNode %s", this.Name);
        this.Properties = m.readProperties();
        //writefln("Properties: %s",this.Properties);
        this.Widgets = getWidgets();
    }

    Widget[] getWidgets()
    {
        Widget[] widgets;
        with (M)
        {
            assert(Word == "{", "Not at right position reading widget content!");
            Ptr++;

            while (Word != "}")
                widgets ~= new Widget(M);

            //Skip the last "}"
            Ptr++;
        }

        return widgets;
    }

    bool hasFlag(string name)
    {
        return this.Properties.canFind!(x => x.Name == name);
    }

    override string generate()
    {
        string code;
        int x, y, w = 100, h = 100;

        if (hasFlag("xywh"))
            this.Properties.get!string("xywh").formattedRead("%d %d %d %d", x, y, w, h);

        string label;
        if (hasFlag("label"))
            label = this.Properties.get!string("label");

        string visibility = getFlag("private") ? "private" : "public";

        string superclass = "Double_Window";

        if (hasFlag("class"))
            superclass = this.get!string("class");
        code ~= "%s class %s: %s\n".format(visibility, Name, superclass.asClassName);
        code ~= "{\n";
        {
            foreach (child; Widgets)
            {
                code ~= child.declare ~ "\n";
            }

            code ~= "this(int x=%d, int y=%d, int w=%d, int h=%d, string l=\"%s\")\n".format(x,
                    y, w, h, label);
            code ~= "{\n";
            {
                code ~= "super(x,y,w,h,l);\n";
                //if (hasFlag("box"))
                //  code ~= "this.box = Boxtype.%s;\n".format(get!string("box"));

                foreach (child; Widgets)
                {
                    code ~= child.generate;
                }
            }
            code ~= "}\n";
        }
        code ~= "}\n";

        return code;
    }

    bool getFlag(string name)
    {
        return this.Properties.getFlag(name);
    }

    T get(T)(string name)
    {
        return Properties.get!T(name);
    }
}

class Widget
{
    static int TempNameCount = 0;
    static Widget[] all;

    bool Anon = false;
    string Name;
    string Type;

    Property[] Properties;
    string[] Words;

    Widget Parent = null;
    Widget[] Children;

    StateMachine M;

    this(StateMachine m, Widget parent = null)
    {
        all ~= this;

        this.Parent = parent;
        this.M = m;
        this.Type = M.readString();
        this.Name = M.readString();
        if (this.Name.length == 0)
        {
            this.Anon = true;
            this.Name = "tempname%02d".format(Widget.TempNameCount++);
        }
        //writefln(pad("\t", depth) ~ "Widget %s(%s)", this.Name, this.Type);
        this.Properties = M.readProperties;
        //writefln("Properties: %s",this.Properties);
        if (M.Word == "{")
        {
            M.Ptr++;
            while (M.Word != "}")
            {
                Children ~= new Widget(m, this);
            }
            //Skip the last "}"
            M.Ptr++;
        }
    }

    string declare()
    {
        string code;
        string visibility = "public";

        if (getFlag("protected"))
            visibility = "protected";
        else if (getFlag("private"))
        {
            visibility = "private";
        }

        if (!this.Anon)
        {
            if (this.Type == "decl")
                code = "%s %s;\n".format(visibility, this.Name);
            else
                code = "%s %s %s;\n".format(visibility, realType.asClassName, this.Name);
        }
        else
        {
            code = "//Anon %s %s\n".format(this.Name, realType.asClassName);
        }
        foreach (child; Children)
        {
            code ~= child.declare;
        }

        return code;
    }

    string realType()
    {
        if (hasFlag("class"))
            return this.get!string("class");
        return this.Type;
    }

    string generate()
    {
        string code;

        if (Type == "decl")
        {
            return "";
        }

        if (this.Anon)
            code ~= "%s ".format(this.realType.asClassName);

        string label;
        if (hasFlag("label"))
        {
            label = ",\"%s\"".format(get!string("label"));
        }

        //code ~= "//%s\n".format(this.Properties);
        code ~= "%s=new %s(%(%d, %)%s);\n".format(this.Name,
                this.realType.asClassName, this.get!string("xywh").split(" ")
                .map!(x => x.to!int), label);

        /////////PROPERTIES/////////
        void AssignFlag(string property, string fieldName = null,
                string function(string v) transform = (string x) => x)
        {
            if (fieldName == null)
                fieldName = property;

            if (hasFlag(property))
            {
                code ~= "%s.%s = %s;\n".format(this.Name, fieldName,
                        transform(this.get!string(property)));
            }
        }

        AssignFlag("box", "box", x => "Boxtype." ~ x.toUglyBoxName);
        AssignFlag("down_box", "down_box", x => "Boxtype." ~ x.toUglyBoxName);
        AssignFlag("color");
        AssignFlag("labelsize");
        AssignFlag("labelcolor");
        AssignFlag("labelfont");
        AssignFlag("shortcut");
        AssignFlag("align", "_align");
        AssignFlag("selection_color");
        AssignFlag("tooltip");
        AssignFlag("value");
        AssignFlag("label_type");
        AssignFlag("when");
        AssignFlag("minimum");
        AssignFlag("maximum");
        AssignFlag("step");
        AssignFlag("slider_size");
        AssignFlag("textfont");
        AssignFlag("textsize");
        AssignFlag("textcolor");

        if (getFlag("resizable"))
            code ~= "%s.parent.resizable=%s;".format(this.Name, this.Name);

        if (getFlag("noborder"))
            code ~= "%s.border=false;".format(this.Name);
        if (getFlag("modal"))
            code ~= "%s.modal();".format(this.Name);
        if (getFlag("deactivate"))
            code ~= "%s.deactivate();".format(this.Name);
        if (getFlag("hotspot"))
            code ~= "%s.hotspot();".format(this.Name);

        if (Children.length > 0)
        {
            code ~= "{\n";
            code ~= "scope(exit) %s.end();\n".format(this.Name);
            foreach (child; Children)
            {
                code ~= child.generate;
                code ~= "\n";
            }
            code ~= "}\n";
        }

        return code;
    }

    int depth()
    {
        Widget ptr = this;
        int ret = 0;
        while (ptr.Parent !is null)
        {
            ret++;
            ptr = ptr.Parent;
        }

        return ret;
    }

    bool hasFlag(string name)
    {
        return this.Properties.canFind!(x => x.Name == name);
    }

    bool getFlag(string name)
    {
        return this.Properties.getFlag(name);
    }

    T get(T)(string name)
    {
        return Properties.get!T(name);
    }
}

abstract class Node
{
    string generate();
}

class VersionNode : Node
{
    string Version;

    this(string[] words)
    {
        this.Version = words[0];
    }

    override string generate()
    {
        return "//Generated using FLTK Version '%s'\n".format(Version);
    }
}

class HeaderNode : Node
{
    string Key;
    string[] Value;

    this(string[] words)
    {
        this.Key = words[0];
        this.Value = words[1 .. $];
    }

    override string generate()
    {
        return "//%s = '%s'\n".format(this.Key, this.Value.join(" "));
    }
}

class CommentNode : Node
{
    string[] RawComment;

    this(string[] words)
    {
        this.RawComment = words;
    }

    override string generate()
    {
        return "/*\n%s\n*/\n".format(this.RawComment.join(" "));
    }
}

class DeclNode : Node
{
    string[] Decl;
    Property[] Properties;

    this(string[] words, Property[] properties)
    {
        this.Decl = words;
        this.Properties = properties;
    }

    override string generate()
    {
        string visibility = "public";

        if (this.Properties.getFlag("private"))
            visibility = "private";

        if (this.Properties.getFlag("protected"))
            visibility = "protected";
        return "%s%s\n".format(visibility, Decl.join("\n"));
    }
}

class FunctionNode : Node
{
    string Name;
    Property[] Properties;
    string Code;

    this(string fname, Property[] properties, string code)
    {
        this.Name = fname;
        this.Properties = properties;
        this.Code=code;
    }

    override string generate()
    {
        string visibility = "public";

        if (this.Properties.getFlag("private"))
            visibility = "private";

        if (this.Properties.getFlag("protected"))
            visibility = "protected";

        string code = "\n//%s function %s\n".format(visibility, this.Name);
        
        foreach(l; Code.split("\n")){
            code~="//"~l;
        }

        return code~"\n";
    }
}
