/* ----------macra wykorzystywane w projekcie----------------- */

/* przypisanie bilbioteki do zapisywania funkcji */
options DLCREATEDIR;
%macro working();
%if &SYSSCP.=WIN %then %do;
libname funk "C:\funkcjeProjekt";
libname funk "C:\funkcjeProjekt\funkcje";
%end;
%else %do;
libname funk "~/funkcjeProjekt";
libname funk "~/funkcjeProjekt/funkcje";
%end;
%mend working;
%working();


/* -------------------macro nr 1---------------------------------- */


/* macro pomocnicze sprawdzajace czy istnieje zmienna w datsetcie */
/* autorstwa Hoffmana i Stauffa */

%macro varexist
/*----------------------------------------------------------------------
Check for the existence of a specified variable.
----------------------------------------------------------------------*/
(ds        /* Data set name */
,var       /* Variable name */
,info      /* LEN = length of variable */
           /* FMT = format of variable */
           /* INFMT = informat of variable */
           /* LABEL = label of variable */
           /* NAME = name in case as stored in dataset */
           /* TYPE  = type of variable (N or C) */
/* Default is to return the variable number  */
);

/*----------------------------------------------------------------------
This code was developed by HOFFMAN CONSULTING as part of a FREEWARE
macro tool set. Its use is restricted to current and former clients of
HOFFMAN CONSULTING as well as other professional colleagues. Questions
and suggestions may be sent to TRHoffman@sprynet.com.
-----------------------------------------------------------------------
Usage:

%if %varexist(&data,NAME)
 %then %put input data set contains variable NAME;

%put Variable &column in &data has type %varexist(&data,&column,type);
------------------------------------------------------------------------
Notes:

The macro calls resolves to 0 when either the data set does not exist
or the variable is not in the specified data set. Invalid values for
the INFO parameter returns a SAS ERROR message.
-----------------------------------------------------------------------
History:

12DEC98 TRHoffman Creation
28NOV99 TRHoffman Added info parameter (thanks Paulette Staum).
----------------------------------------------------------------------*/
%local dsid rc varnum;

%*----------------------------------------------------------------------
Use the SYSFUNC macro to execute the SCL OPEN, VARNUM,
other variable information and CLOSE functions.
-----------------------------------------------------------------------;
%let dsid = %sysfunc(open(&ds));

%if (&dsid) %then %do;
  %let varnum = %sysfunc(varnum(&dsid,&var));

  %if (&varnum) & %length(&info) %then
    %sysfunc(var&info(&dsid,&varnum))
  ;
  %else
    &varnum
  ;

  %let rc = %sysfunc(close(&dsid));
%end;

%else 0;

%mend varexist;

/* -------------------macro nr 3---------------------------------- */

%macro datasetExists(ds);
 /* sprawdzenie czy istnieje podany zbior ds */

 /* macro zwraca wartosc 1 jesli zbior nie istnieje, */
 /* 0 w przeciwnym przypadku */

 %let ifLibrary = %sysfunc(countc(&ds.,%str(.)));
 
 %if &ifLibrary. %then 
  %do;
   %put Sprawdzam czy istnieje zbior %upcase(%scan(&ds.,2,%str(.))) w bibliotece %upcase(%scan(&ds.,1,%str(.))) ->;
  %end;
  
 %else 
  %do;
   %put Sprawdzam czy istnieje zbior %upcase(&ds.) w bibliotece WORK ->;

  %end;
  
 %if %sysfunc(exist(&ds.)) %then 
  %do;
   %put zbior zostal znaleziony ->;
   0
  %end;
  
  %else 
   %do;
    %put Nie ma takiego zbioru, opuszczam makro;
    1
   %end; 

%mend datasetExists;

/* -------------------macro nr 4---------------------------------- */

/* macro tworzace klucz glowny na zbiorze */

%macro setPrimaryKey(ds=, PK=);

 %local ifLibrary library dataset;

 %if %datasetExists(&ds.) %then %return;
 
 %if %varexist(&ds., &PK.)= 0 %then %return;
 %else %put zmienna &PK. zostala znaleziona w zbiorze &ds.;
 
 %let ifLibrary = %sysfunc(countc(&ds.,%str(.)));
 
  %if &ifLibrary. %then 
  %do;
   %let library = %upcase(%scan(&ds.,1,%str(.)));
   %let dataset = %upcase(%scan(&ds.,2,%str(.)));
  %end;
  %else 
   %do;
    %let library = WORK;
    %let dataset = &ds.;
   %end;

%put &library.;

%put &dataset.;
 
 proc datasets lib=&library. nolist;
   modify &dataset.;
   ic create PK_&library._&dataset.=primary key(&PK.)
   MESSAGE='values of primary key must be uniqe and not null'
   MSGTYPE=user;
quit;
 
 
%mend setPrimaryKey;


/* -------------------macro nr 5---------------------------------- */

%macro czyWartoscJestWZbiorze(wartosc,zmienna ,zbior);

 %if %datasetExists(&zbior.) %then 
  %do; 
   %return; 
  %end;
  
  /* sprawdzenie czy odpowiednie zmienne istnieją w zbiorze klienci */
 %if %eval(not(%varexist(&zbior., &zmienna.)))  %then 
  %do;
   %put W zbiorze &zbior. nie ma zmiennej: &zmienna.;
   %return;
  %end;

 %global czy&zmienna.;

    proc sql noprint;
        select count(*)
        into :czy&zmienna.
        from &zbior.
        where &zmienna. = &wartosc.;
    quit;

%mend czyWartoscJestWZbiorze;


/* -------------------funkcja nr 1---------------------------------- */

/* przypisanie bilbioteki do zapisywania funkcji */
options DLCREATEDIR;
%macro working();
%if &SYSSCP.=WIN %then %do;
libname funk "C:\funkcjeProjekt";
libname funk "C:\funkcjeProjekt\funkcje";
%end;
%else %do;
libname funk "~/funkcjeProjekt";
libname funk "~/funkcjeProjekt/funkcje";
%end;
%mend working;
%working();

options cmplib = _null_;

proc fcmp outlib=funk.funkcje.projekt;
/* funkcja oblicza oraz zwraca odległość między dwoma  */
/* punktami polozonymi na kuli ziemskiej, uzywajac wzoru Haversine’a */
/* ------------------------------------------------------------------- */
/* dane wejsciowe:  */
/*  - xLat - szerokosc geograficzna pierwszego punktu */
/*  - xLong - dlugosc geograficzna pierwszego punktu */
/*  - yLat - szerokosc geograficzna drugiego punktu */
/*  - yLong - dlugosc geograficzna drugiego punktu */
/* ------------------------------------------------------------------- */
/* dane wyjsciowe: */
/*  - odleglosc - odległość między dwoma punktami */
 
 
 function obliczOdleglosc(xLat, xLong, yLat, yLong);
 
  R = 6371; /* <- dlugosc promienia ziemii */
 
  /*przeliczenie na radiany */
  radxLat = xLat*constant('pi')/180;
  radxLong = xLong*constant('pi')/180;
  radyLat = yLat*constant('pi')/180;
  radyLong = yLong*constant('pi')/180;
  
  deltaLat = abs(radxLat - radyLat);
  deltaLong = abs(radxLong - radyLong);
  
  d = 2 * R * arsin(sqrt((1 - cos(deltaLat) + cos(radxLat)*cos(radyLat)*(1-cos(deltaLong)))/2));
  return(d);
 
 endsub;
 
run;

options cmplib = (funk.funkcje _DISPLAYLOC_);

proc print data=funk.funkcje;
 where NValue;
run;

/* -------------------funkcja nr 2---------------------------------- */



proc fcmp outlib=funk.funkcje.projekt;

 function obliczDate(data, godzina, dodawaneGodziny);
 
  nowaGodz = godzina + dodawaneGodziny;
 
  liczbaDni = floor(nowaGodz/24);
  liczbaGodzin = floor(nowaGodz - 24*liczbaDni);
  liczbaMinut = round((nowaGodz - liczbaDni*24 -liczbaGodzin)*60,0.01);
 
  nowaGodzina = dhms(data + liczbaDni, liczbaGodzin, liczbaMinut,0 );
 
   return(nowaGodzina);
  endsub;
 
run;


options cmplib = (funk.funkcje _DISPLAYLOC_);

/* -------------------funkcja nr 3---------------------------------- */


proc fcmp outlib=funk.funkcje.projekt;

 function obliczWydaloneCO2(dlugoscTrasy, kategoriaSamolotu $);
 
/* Zakladamy nastepujaca zaleznosc:  */
/*  M_CO2 = EF * F */
/* Gdzie: */
/*  */
/* *M_CO2 – masa wydalonego [kg], */
/* *F – ilość spalonego paliwa [kg], */
/* *EF – emisyjny współczynnik paliwa\wa [kg * CO2 /kg paliwa]. */
/*  */
/* Ustalamy, ze EF = 3.15 */
   EF = 3.15;

   if kategoriaSamolotu = 'big' then 
   wspolczynnik =6;
   else if kategoriaSamolotu = 'medium' then wspolczynnik =3;
   else wspolczynnik =1.5;

   spalonePaliwo = dlugoscTrasy*wspolczynnik;
   
   M_CO2 = spalonePaliwo*EF;
 
   return(M_CO2);
  endsub;
 
run;


