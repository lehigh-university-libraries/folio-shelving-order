# FOLIO Shelving Order

This provides a simple web service to map a call number into a FOLIO "shelving order" string.  See the FOLIO wiki for a [general explanation of shelving order](https://folio-org.atlassian.net/wiki/spaces/FOLIJET/pages/1395977/Call+Numbers+Browse).

## Non-standard behavior

FOLIO uses the [Marc4J callnum library](https://github.com/marc4j/marc4j/tree/master/src/org/marc4j/callnum) to perform this mapping, to what it terms a "shelf key".  For Dewey call numbers, that library assumes (per the standard) that the cutter's numeric portion is 1-3 digits long.  It generates an invalid shelf key when this constraint is violated.

This web service uses [a fork of that library](https://github.com/lehigh-university-libraries/marc4j) to remove the 1-3 digit constraint, and generate a shelf key / shelving order for any positive length numeric portion of the cutter.
