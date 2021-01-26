import std.stdio;
import std.format;
import std.algorithm.searching;
import std.algorithm.iteration;
import std.file;
import std.array;
import std.range;
import std.string;
import std.conv;

static string[] FlagProperties = "private protected open selected resizable visible noborder modal hide deactivate divider hotspot"
    .split(" ");
static string[] ValueProperties = "align xywh label type class box color tooltip image deimage shortcut down_box value selection_color label_type labelcolor labelfont labelsize when minimum maximum step slider_size textfont textsize textcolor code0 code1 code2 code3"
    .split(" ");

string[] pretty_box_names = [
    "NO_BOX", "FLAT_BOX", "UP_BOX", "DOWN_BOX", "UP_FRAME", "DOWN_FRAME",
    "THIN_UP_BOX", "THIN_DOWN_BOX", "THIN_UP_FRAME", "THIN_DOWN_FRAME",
    "ENGRAVED_BOX", "EMBOSSED_BOX", "ENGRAVED_FRAME", "EMBOSSED_FRAME",
    "BORDER_BOX", "SHADOW_BOX", "BORDER_FRAME", "SHADOW_FRAME", "ROUNDED_BOX",
    "RSHADOW_BOX", "ROUNDED_FRAME", "RFLAT_BOX", "ROUND_UP_BOX", "ROUND_DOWN_BOX",
    "DIAMOND_UP_BOX", "DIAMOND_DOWN_BOX", "OVAL_BOX", "OSHADOW_BOX", "OVAL_FRAME",
    "OFLAT_BOX", "PLASTIC_UP_BOX", "PLASTIC_DOWN_BOX", "PLASTIC_UP_FRAME",
    "PLASTIC_DOWN_FRAME", "PLASTIC_THIN_UP_BOX", "PLASTIC_THIN_DOWN_BOX",
    "PLASTIC_ROUND_UP_BOX", "PLASTIC_ROUND_DOWN_BOX",
    "GTK_UP_BOX", "GTK_DOWN_BOX", "GTK_UP_FRAME", "GTK_DOWN_FRAME",
    "GTK_THIN_UP_BOX", "GTK_THIN_DOWN_BOX", "GTK_THIN_UP_FRAME",
    "GTK_THIN_DOWN_FRAME", "GTK_ROUND_UP_BOX", "GTK_ROUND_DOWN_BOX",
    "GLEAM_UP_BOX", "GLEAM_DOWN_BOX", "GLEAM_UP_FRAME", "GLEAM_DOWN_FRAME",
    "GLEAM_THIN_UP_BOX", "GLEAM_THIN_DOWN_BOX", "GLEAM_ROUND_UP_BOX",
    "GLEAM_ROUND_DOWN_BOX"
];

string[] ugly_box_names = [
    "FL_NO_BOX", "FL_FLAT_BOX", "FL_UP_BOX", "FL_DOWN_BOX", "FL_UP_FRAME",
    "FL_DOWN_FRAME", "FL_THIN_UP_BOX", "FL_THIN_DOWN_BOX",
    "FL_THIN_UP_FRAME", "FL_THIN_DOWN_FRAME", "FL_ENGRAVED_BOX",
    "FL_EMBOSSED_BOX", "FL_ENGRAVED_FRAME", "FL_EMBOSSED_FRAME",
    "FL_BORDER_BOX", "_FL_SHADOW_BOX", "FL_BORDER_FRAME", "_FL_SHADOW_FRAME",
    "_FL_ROUNDED_BOX", "_FL_RSHADOW_BOX", "_FL_ROUNDED_FRAME",
    "_FL_RFLAT_BOX", "_FL_ROUND_UP_BOX", "_FL_ROUND_DOWN_BOX",
    "_FL_DIAMOND_UP_BOX", "_FL_DIAMOND_DOWN_BOX", "_FL_OVAL_BOX",
    "_FL_OSHADOW_BOX", "_FL_OVAL_FRAME", "_FL_OFLAT_BOX",
    "_FL_PLASTIC_UP_BOX", "_FL_PLASTIC_DOWN_BOX", "_FL_PLASTIC_UP_FRAME",
    "_FL_PLASTIC_DOWN_FRAME", "_FL_PLASTIC_THIN_UP_BOX",
    "_FL_PLASTIC_THIN_DOWN_BOX", "_FL_PLASTIC_ROUND_UP_BOX",
    "_FL_PLASTIC_ROUND_DOWN_BOX", "_FL_GTK_UP_BOX", "_FL_GTK_DOWN_BOX",
    "_FL_GTK_UP_FRAME", "_FL_GTK_DOWN_FRAME", "_FL_GTK_THIN_UP_BOX",
    "_FL_GTK_THIN_DOWN_BOX", "_FL_GTK_THIN_UP_FRAME",
    "_FL_GTK_THIN_DOWN_FRAME", "_FL_GTK_ROUND_UP_BOX",
    "_FL_GTK_ROUND_DOWN_BOX", "_FL_GLEAM_UP_BOX", "_FL_GLEAM_DOWN_BOX",
    "_FL_GLEAM_UP_FRAME", "_FL_GLEAM_DOWN_FRAME", "_FL_GLEAM_THIN_UP_BOX",
    "_FL_GLEAM_THIN_DOWN_BOX", "_FL_GLEAM_ROUND_UP_BOX",
    "_FL_GLEAM_ROUND_DOWN_BOX"
];


string toUglyBoxName(string prettyName){
    for (int i=0;i<pretty_box_names.length;i++){
        if (pretty_box_names[i]==prettyName){
            return ugly_box_names[i];
        }
    }
    return "FL_FLAT_BOX";
}


bool getFlag(Property[] properties, string flagproperty)
{
    assert(Property.FlagProperties.canFind(flagproperty));

    return properties.canFind!(x => x.Name == flagproperty);
}

string asClassName(string realname)
{
    if (realname.length >= 3 && realname[0 .. 3] == "Fl_")
    {
        return realname[3 .. $];
    }

    return realname;
}

T get(T)(Property[] properties, string name)
{
    assert(Property.ValueProperties.canFind(name));

    foreach (prop; properties)
    {
        if (prop.Name == name)
            return prop.Value.to!T;
    }

    assert(0);
}
