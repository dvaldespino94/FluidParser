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

class StateMachine
{
    string[] Words;
    int Ptr;

    this(string data)
    {
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

        Ptr = 0;
        while (Ptr < Words.length)
        {
            switch (Word)
            {
            case "version":
                Ptr++;
                readString();
                //writefln("VERSION '%s'", readString());
                continue;

            case "header_name":
                Ptr++;
                readString();
                //writefln("HEADER_NAME '%s'", readString());
                continue;

            case "code_name":
                Ptr++;
                readString();
                //writefln("CODE_NAME '%s'", readString());
                continue;

            case "comment":
                Ptr++;
                readString();
                readProperties();
                //writefln("COMMENT:\n===========\n%s\n===========", readString());
                //writefln("Reading comment's properties starting @%d('%s')", Ptr, Words[Ptr]);
                //writefln("\tPROPERTIES: %s", readProperties());
                continue;

            case "decl":
                Ptr++;
                readString();
                readProperties();
                //writefln("DECL:\n===========\n%s\n===========", readString());
                //writefln("\tPROPERTIES: %s", readProperties());
                continue;

            case "Function":
                Ptr++;
                readString();
                readProperties();
                //writefln("FUNCTION:\n===========\n%s\n===========", readString());
                //writefln("\tPROPERTIES: %s", readProperties());
                continue;

            case "widget_class":
                Ptr++;
                auto w=new WidgetClass(this);
                continue;

            default:
                assert(0, "Unknown id '%s'".format(Word));
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
