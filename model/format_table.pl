#!/usr/bin/perl
#*********************************************************************
# 
# S3MO5 model -  emulateur MO5
# 
#*********************************************************************
# 
# $Revision: $
# $Date: $
# $Source: $
# $Log: $
#
#*********************************************************************

# read file
for($l=0;$l<16*3;$l++)
{
  for($c=0;$c<16;$c++)
  {
    while(<STDIN>)
    {
      s/RELATIVE2/RELATIVE/g;
      s/INHERENT[0-3A-Z]+/INHERENT/g;
      
      if($_ =~ /(name_|NULL)([a-z0-9]*) *,[ 0-9a-zA-Z]+,([A-Z0-9]+) *,[ _0-9a-zA-Z]+, *([0-9]+) /)
      {
        if(($ARGV[0] eq $3) or ($ARGV[0] eq "all"))
        {
          $opcode[$l][$c] = "$2 $4";
          $mode[$l][$c]   = $3;
        }
        last;
      }
    }
  }
}
# print 2D table

for($l=0;$l<3*16;$l++)
{
  for($c=0;$c<16*13+1;$c++)
  {
    if($c%13)
    {
      print "-";
    }
    else
    {
      print "+";
    }
  }
  print "\n";
  for($c=0;$c<16;$c++)
  {
    print "|";
    print $opcode[$l][$c];
    for($p=0;$p<12-length($opcode[$l][$c]);$p++)
    {
      print " ";
    }
  }
  print "|\n";
  for($c=0;$c<16;$c++)
  {
    print "|";
    print $mode[$l][$c];
    for($p=0;$p<12-length($mode[$l][$c]);$p++)
    {
      print " ";
    }
  }
  print "|\n";
}

