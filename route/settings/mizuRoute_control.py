"""
Python module to read in a sample mizuRoute control file into a data type
as an array of keys as well as a dictionary of the values. The Dictionary
can then be modified and output as a new file.

Erik Kluzek
"""

import sys, re

sys.path.append( "../../cime/scripts/lib" );

from CIME.XML.standard_module_setup import *
from CIME.utils import expect, convert_to_string, convert_to_type

import six

logger = logging.getLogger(__name__)

class mizuRoute_control(object):

   """ Object to hold a dictionary of settings for mizuRoute control """

   # Class Data:
   fileRead = False                         # If file has been read or not
   dict = {}                                # Dictionary of control elments
   keyList = []                             # List of keys for control elements
   lines = []                               # Lines of the entire file read in
   desc = []                                # Description for each control element
   lineMatch = '^<(.+?)>\s+(\S+)\s+\!(.+)$' # Pattern to match for lines
   longestName = 0                          # Longest name
   longestValue = 0                         # Longest value

   def read( self, infile ):
       """
       Read and parse a mizuRoute control file
       """
       # Read the whole file and save each line as object data
       logger.debug( "read in file: "+infile )
       if ( not os.path.exists(infile) ):
          expect( False, "Input file to read does NOT exist: "+infile )

       ctlfile = open( infile, "r" )
       self.lines = ctlfile.readlines()
       ctlfile.close()

       # Loop through each line in the file
       for line in self.lines:
          # Ignore comment lines
          if ( not line.find( "!" ) == 0 ):
             match = re.search( self.lineMatch, line )
             if ( not match ):
                expect( False, "Error in reading in line:"+line )
             else:
                name = match.group(1)
                value = match.group(2)
                comment = match.group(3)
                self.set( name, value )
                self.desc.append(comment)


       # Mark the file as read
       logger.debug( "File read" )
       self.fileRead = True


   def write( self, outfile ):
       """
       Write out a mizuRoute control file
       """
       logger.debug( "Write out file: "+outfile )

       vallen  = str(self.longestValue + 5)
       # Loop through each line in the file
       for line in self.lines:
          # Write comment lines as is
          if ( line.find( "!" ) == 0 ):
             print( "%s" % (line) )
          else:
             match = re.search( self.lineMatch, line )
             if ( not match ):
                expect( False, "Error in for output line:"+line )
             name = match.group(1)
             value = self.get( name )
             comment = match.group(3)
             namelen = str(self.longestName - len(name) + 4)
             format = "<%s>%"+namelen+"s   %"+vallen+"s    ! %s"
             print( format % (name, " ", value, comment) )

   def get( self, name ):
       """
       Return an element from the control file
       """
       if ( self.__is_valid_name( name ) ):
          return( self.dict[name] )
       else:
          return( "UNSET" )

   def set( self, name, value ):
       """
       Set an element in the control file
       """
       if ( not self.__is_valid_name( name ) ):
          self.keyList.append(name)

       self.dict[name] = value
       # Check for longest value and name
       if ( len(name)  > self.longestName  ): self.longestName  = len(name)
       if ( len(value) > self.longestValue ): self.longestValue = len(value)


   def __is_valid_name( self, name ):
       """
       Check if the name is valid
       """
       if ( self.is_read() ):
          try:
             idx =  self.keyList.index(name) 
             return( True )
          except  ValueError:
             return( False )
       else:
          return( False )

   def is_read( self ):
       """
       Check if file has been read
       """
       return( self.fileRead )

#
# Unit testing for above classes
#
import unittest


class test_mizuRoute_control(unittest.TestCase):

   def setUp( self ):
       self.ctl = mizuRoute_control()

   def test_is_read( self ):
       self.assertFalse( self.ctl.is_read() )
       self.ctl.read( "SAMPLE.control" )
       self.assertTrue( self.ctl.is_read() )

   def test_get_not_read( self ):
       value = self.ctl.get( "thing" )
       self.assertEqual( value, "UNSET" )

   def test_non_existant_file( self ):
       self.assertRaises( SystemExit, self.ctl.read, "file_does_NOT_EXIST.zztop" )

   def test_bad_file( self ):
       self.assertRaises( SystemExit, self.ctl.read, "README.md" )

   def test_get_after_set( self ):
       name = "thingwithlongname"
       value = "valuereturned"
       self.ctl.read( "SAMPLE.control" )
       self.ctl.set( name, value )
       getvalue = self.ctl.get( name )
       self.assertEqual( getvalue, value )

   def test_get_bad_name_after_set( self ):
       name = "thingwithlongname"
       name2 = name + "even_longer"
       value = "valuereturned"
       self.ctl.read( "SAMPLE.control" )
       self.ctl.set( name, value )
       getvalue = self.ctl.get( name2 )
       self.assertEqual( getvalue, "UNSET" )

   def test_write( self ):
       self.ctl.read( "SAMPLE.control" )
       self.ctl.write( "mizuRoute_in" )

if __name__ == '__main__':
     unittest.main()