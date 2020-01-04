Transposing and pivoting when id values have duplicates

github
https://tinyurl.com/rulu9ru
https://github.com/rogerjdeangelis/utl-transposing-and-pivoting-when-id-values-have-duplicates

I was surprised that I could not get Art's transpose macro to do this.
The problem is mutiples on grp and log?

StackOverflow
https://tinyurl.com/vuk36vl
https://stackoverflow.com/questions/59542167/sas-proc-transpose-reoccurring-id-names-with-let

More general solution by Richard but requires a sort.
https://stackoverflow.com/users/1249962/richard


*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;
data have;
  input grp$ hrs log$;
cards4;
A 1 OFF
A 2 ON
A 3 ON
A 4 ON
B 5 OFF
B 6 ON
B 7 ON
B 8 OFF
;;;;
run;

WORK.HAVE total obs=8

  GRP    HRS    LOG

   A      1     OFF
   A      2     ON
   A      3     ON
   A      4     ON
   B      5     OFF
   B      6     ON
   B      7     ON
   B      8     OFF

*           _
 _ __ _   _| | ___  ___
| '__| | | | |/ _ \/ __|
| |  | |_| | |  __/\__ \
|_|   \__,_|_|\___||___/

;

prep for transpose

 GRP    HRS    LOG    LOG   Add Sequence number then transpose

  A      1     OFF |  OFF1   proc transpose data=havSeq out=havXpo;
  A      2     ON  |  ON1      by grp;
  A      3     ON  |  ON2      id log;
  A      4     ON  |  ON3      var hrs;
  B      5     OFF |  OFF1   run;quit;
  B      6     ON  |  ON1
  B      7     ON  |  ON2
  B      8     OFF |  OFF2

*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

WORK.WANT total obs=2

  GRP    _NAME_    OFF1   OFF2   ON1    ON2    ON3

   A      HRS        1      .     2      3      4
   B      HRS        5      8     5      7      .

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

data havCnt / view=havCnt;
  retain off on .;
  set have;
  by grp;
  on = sum(on, (log="ON"));
  off= sum(off,(log="OFF"));
  log = ifc(log="ON",cats(log,on),cats(log,off));
  output;
  if last.grp then call missing(on,off);
  drop on off;
run;quit;

proc transpose data=havCnt out=want;
  by grp;
  id log;
  var hrs;
run;quit;




