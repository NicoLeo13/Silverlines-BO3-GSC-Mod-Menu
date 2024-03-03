BGBName(gumname)
{
    return TableLookupIString("gamedata/stats/zm/zm_statstable.csv", 4, gumname, 3);
}
