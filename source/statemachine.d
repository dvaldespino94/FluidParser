import std.stdio;
import std.format;
import std.algorithm.searching;
import std.algorithm.iteration;
import std.file;
import std.array;
import std.range;
import std.string;

import types;

string pad(char c, int count)
{
    return pad("%c".format(c), count);
}

string pad(string c, int count)
{
    string ret;
    for (int i = 0; i < count; i++)
    {
        ret ~= c;
    }

    return ret;
}

string[] tokenize(string data)
{
    string[] Words;
    foreach (line; data.split("\n").filter!(x => x.length > 0 && x.strip[0] != '#'))
    {
        string word;

        foreach (c; line)
        {
            switch (c)
            {
            case '}':
            case '{':
                if (!word.empty)
                {
                    Words ~= word;
                    word = "";
                }
                Words ~= "%c".format(c);
                break;

            case '\t':
            case ' ':
            case '\n':
                if (!word.empty)
                {
                    Words ~= word;
                    word = "";
                }
                break;

            default:
                word ~= c;
            }
        }
        if (!word.empty)
            Words ~= word;
    }

    return Words;
}

class StateMachine
{
    string[] Words;
    Node[] Nodes;
    int Ptr;

    this(string data)
    {
        Words=tokenize(data);

        Ptr = 0;
        while (Ptr < Words.length)
        {
            switch (Word)
            {
            case "version":
                Ptr++;
                Nodes ~= new VersionNode([readString()]);
                continue;

            case "header_name":
                Ptr++;
                Nodes ~= new HeaderNode(["header_name", readString()]);
                continue;

            case "code_name":
                Ptr++;
                Nodes ~= new HeaderNode(["code_name", readString()]);
                continue;

            case "comment":
                Ptr++;
                Nodes ~= new CommentNode([readString()]);
                //I don't know what to do with this properties, so, just drop them
                readProperties();
                continue;

            case "decl":
                Ptr++;
                Nodes ~= new DeclNode([readString], readProperties());
                continue;

            case "Function":
                Ptr++;
                Nodes ~= new FunctionNode(readString(), readProperties(), readString());
                continue;

            case "widget_class":
                Ptr++;
                Nodes ~= new WidgetNode(this);
                continue;

            default:
                assert(0, "Unknown id '%s' @%d\n%(%s %)\n".format(Word, Ptr,
                        Words[Ptr - 5 .. Ptr + 5]));
            }
        }
    }

    string Word()
    {
        return Words[Ptr];
    }

    string readString()
    {
        if (Words[Ptr] == "{")
        {
            int depth = 1;
            string wholeString;
            Ptr++;

            while (true)
            {
                if (Words[Ptr] == "{")
                    depth++;

                if (Words[Ptr] == "}")
                    depth--;

                if (depth == 0)
                    break;

                wholeString ~= Words[Ptr] ~ " ";

                Ptr++;
            }

            //Skip the last '}'
            Ptr++;
            return wholeString.strip;
        }
        //Return the current word and point to the next
        return Words[Ptr++];
    }

    Property[] readProperties()
    {
        Property[] ret;

        assert(Word == "{", "readProperties should start @ opening brace");
        Ptr++;

        while (Words[Ptr] != "}")
            ret ~= new Property(this);

        //Skip the closing "}"
        Ptr++;

        return ret;
    }
}
