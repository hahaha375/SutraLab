# SutraLab
Post-process code for USGS-SUTRA

**Full documentation:** [docs/SutraLab_Documentation.md](docs/SutraLab_Documentation.md)

IMPLIMENTED FUNCTIONS:
------------------------------------------------------------------------------------------------

readNOD  -- read \*.NOD file to MATLAB

readELE  -- read \*.ELE file to MATLAB

readBCOP -- read \*.BCOP file to MATLAB

readBCOF -- read \*.BCOF file to MATLAB

inpObj   -- read \*.INP file to MATLAB


type help functions in MATLAB to see how to use these functions




ABOUT THE DRECTORIES
------------------------------------------------------------------------------------------------

etc  -- some parsing subfunctions required for read functions

misc -- analytical solutions and constitutive relationships

read -- list of functions for reading input and output files

sutraset -- subfunctions required particularly for sutraSET

please help us improve this package by file bugs and merge request:
several simple rules to make code consistent.
1. try to use SUTRA variable name as priority.
2. if the variable is not in SUTRA original code,
   variables(function names) are named as small case with underscores, it does not matter
   whether it is too long, as long as it is self explainable
3. use tab rather than space to indentate the code



HOW TO USE THE CODE:
------------------------------------------------------------------------------------------------
  Under MATLAB ENVIRONMENT, run:
```matlab
>run('path\_to\_mflab/mfiles/slsetpath.m')
```


to let MATLAB accept the library.


  Then at the simulation directory, run:

```matlab
fil =  readFIL;
inp  = inpObj(fil.basename);
nod  = readNOD(fil.basename);
ele  = readELE( fil.basename);
bcop = readBCOP(fil.basename);
bcof = readBCOF(fil.basename);
```


to read sutra files to MATLAB


