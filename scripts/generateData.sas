/*podlaczenie biblioteki */
libname danepro
base
'/home/u63796376/daneProjekt';
/*----------------Generowanie danych o samolotach------------------------------*/


%macro generujSamoloty(liczbaSamolotow, modele);
/* macro generuje przykladowe dane samolotow */

/* sprawdzenie czy istnieje podany zbior modele */
 
 %if %datasetExists(&modele.) %then 
  %do; 
   %return; 
  %end;

/* przypisanie makrozmiennej liczbaModeli liczbe modeli samolotow  */
/* z zbiorze danych modele */
 %let dsid=%sysfunc(OPEN(&modele.,in));
 %let liczbaModeli=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.));
 
 data danepro.planes;
  %do i = 1 %to &liczbaSamolotow.;
   %let model =%sysfunc(CEIL(%sysfunc(RAND(%str(UNIFORM),0, &liczbaModeli.))));
   planeId = &i.;
   modelId = &model.;
   productionYear = 2024 - (int(RAND("UNIFORM",0,20)));
   
   length status $ 8;
   
   /* ustawienie wartości status = 'active' z prawdopodobienstwem 0.85 */
   /* w przeciwnym przypadku przyjmowana wartosc to 'inactive' */
  
  	u = RAND("UNIFORM");
  	if u <= 0.85 then status = 'active'; else status = 'inactive';
   output;
   
   drop u;
  %end;
 run;
 
 %put utworzono zbior o nazwie PLANES w bibliotece DANEPRO;
 
%mend generujSamoloty;

%generujSamoloty(30, danepro.aircraftsModels )

/*----------------Generowanie danych o klientach------------------------------*/
%macro generujKlientow(liczbaKlientow, nazwiska, imiona, zbiorKlientow=);

 /* sprawdzenie czy istnieja zbiory nazwiska i imiona */
 
 %if %datasetExists(&nazwiska.) %then 
  %do; 
   %return; 
  %end;
 
 %if %datasetExists(&imiona.) %then 
  %do; 
   %return; 
  %end;
 

 /* przyisanie makrozmiennej liczbaNazwisk liczbe nazwisk  */
 /* z zbioru danych nazwiska */
 %let dsid=%sysfunc(OPEN(&nazwiska.,in));
 %let liczbaNazwisk=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.)); 

 /* przyisanie makrozmiennej liczbaImion liczbe imion  */
 /* z zbioru danych imiona */
 %let dsid=%sysfunc(OPEN(&imiona.,in));
 %let liczbaImion=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.));

 data &zbiorKlientow.;
 drop i u idx;
 customerId=.;
 length firstname lastname $ 50;
 
  if 0 then do; set &nazwiska. &imiona.; end; /* wczytanie naglowka zbioru */

  declare hash Nazwiska(dataset: "&nazwiska.");
  Nazwiska.DefineKey('i');
  Nazwiska.DefineData("lastname");
  Nazwiska.DefineDone();
  
  declare hash Imiona(dataset: "&imiona.");
  Imiona.DefineKey('i');
  Imiona.DefineData("firstname");
  Imiona.DefineDone();
 
 call missing(i);
 
 array krajeId [12] _temporary_ (17,24,36,41,59,63,82,163,178,182,184,185);
 
 %do iter = 1 %to &liczbaKlientow.;
 
  i = ceil(%sysevalf(%sysfunc(rand(%STR(UNIFORM)))*&liczbaImion.));
  Nazwiska.find();
 
  i = ceil(%sysevalf(%sysfunc(rand(%STR(UNIFORM)))*&liczbaImion.));
  Imiona.Find();
 
  customerId = &iter.;
 
  length email $ 65;
  email = strip(lastname) || strip(firstname) || "&iter.@email.com";
 
  birthdate = '1JAN2000'd + 365*(INT(rand('beta', 4, 2)*70)  - 55) + INT(rand('UNIFROM',0,365));
  format birthdate date9.;
 
  length loyaltyLevel $ 6; 
  loyaltyLevel = 'first';
  
  length phoneNumber $ 12;
   phoneNumber = cats(
      customerId,
      put(floor(ranuni(0) * 10), 1.), 
      put(floor(ranuni(0) * 10), 1.),
      put(floor(ranuni(0) * 10), 1.),
      put(floor(ranuni(0) * 10), 1.),
      put(floor(ranuni(0) * 10), 1.),
      put(floor(ranuni(0) * 10), 1.)
   );
  
  
  u = rand("UNIFORM");
  
  if u <= 0.4 then countryId = 139;
  else if u <= 0.8 then 
   do;
    idx = CEIL(rand('UNIFORM', 0, 12));
    countryId = krajeId[idx];
   end;
  else 
   do;
    countryId = CEIL(rand('UNIFORM', 0, 193));
   end;
 
  output;
 %end;
 stop;
 run;
 
 %put utworzono zbior o nazwie %upcase(%scan(&zbiorKlientow.,2,%str(.))) w bibliotece %upcase(%scan(&zbiorKlientow.,1,%str(.)));
 

%mend generujKlientow;


%generujKlientow(5000, danepro.nazwiska, danepro.imiona, zbiorKlientow=danepro.customers)

/*----------------Generowanie danych o pracownikach------------------------------*/

%macro generujPracownikow(liczbaPracownikow, nazwiska, imiona, zawody, pracownicy=);

/*  liczbaPracownikow musi byc wieksza niz 1000 */
/*  proporcje w pracownikach będą następujące: */
/*     - Pilot: 25 % */
/* 	   - Flight Attendant: 25 % */
/*     - Air Traffic Controller: 25 % */
/* 	   - Ticketing Agent: 25 % */
/*  do tego pojednym pracowniku w zawodach: */
/*    	- Data Analyst */
/*      - Human Resources Specialist */

  %if %eval(&nazwiska. < 100) %then 
  %do;
   %put liczbaPracownikow musi byc wieksza niz 100, opuszczam macro;
   %return; 
  %end;

 /* sprawdzenie czy podane zbiory istnieja */

 %if %datasetExists(&nazwiska.) %then 
  %do; 
   %return; 
  %end;
 
 %if %datasetExists(&imiona.) %then 
  %do; 
   %return; 
  %end;
  
 %if %datasetExists(&zawody.) %then 
  %do; 
   %return; 
  %end;

  /* przyisanie makrozmiennej liczbaNazwisk liczbe nazwisk  */
 /* z zbioru danych nazwiska */
 %let dsid=%sysfunc(OPEN(&nazwiska.,in));
 %let liczbaNazwisk=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.)); 

 /* przyisanie makrozmiennej liczbaImion liczbe imion  */
 /* z zbioru danych imiona */
 %let dsid=%sysfunc(OPEN(&imiona.,in));
 %let liczbaImion=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.));
 
 /* przyisanie makrozmiennej liczbaZawodow liczbe zawodow  */
 /* z zbioru danych zawody */
 %let dsid=%sysfunc(OPEN(&zawody.,in));
 %let liczbaZawodow=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.));
 
 data &pracownicy.;
  
  drop i;
  employeeId=.;
  length firstname lastname $ 50;
  
  employeeId=1; firstname= "Bartosiewicz";lastname="Piotr"; occupationId=1;
  output;
  
  employeeId=2; firstname= "Ciasteczko";lastname="Krystyna"; occupationId=6;
  output;
 
  if 0 then do; set &nazwiska. &imiona.; end; /* wczytanie naglowka zbioru */

  declare hash Nazwiska(dataset: "&nazwiska.");
  Nazwiska.DefineKey('i');
  Nazwiska.DefineData("lastname");
  Nazwiska.DefineDone();
  
  declare hash Imiona(dataset: "&imiona.");
  Imiona.DefineKey('i');
  Imiona.DefineData("firstname");
  Imiona.DefineDone();
 
  call missing(i);
  
  %let bramka = %sysfunc(floor(%sysevalf(&liczbaPracownikow./4)));
 
  %do iter = 3 %to %eval(&liczbaPracownikow.+2);
   
   i = ceil(%sysevalf(%sysfunc(rand(%STR(UNIFORM)))*&liczbaImion.));
   Nazwiska.find();
 
   i = ceil(%sysevalf(%sysfunc(rand(%STR(UNIFORM)))*&liczbaImion.));
   Imiona.Find();
   
   employeeId = &iter.;
 
   %if %eval(&iter. <= &bramka.) %then 
    %do; 
      occupationId = 2; /*<- piloci */
    %end;
    %else
     %do;
      %if %eval(&iter. <= %eval(2*&bramka.)) %then 
       %do; 
        occupationId = 3; /*<- stewardesi */
       %end;
       
       %else
        %do;
         
         %if %eval(&iter. <= %eval(3*&bramka.)) %then 
          %do; 
           occupationId = 4; /*<- kontolerzy ruchu */
          %end;
        
        %else 
          %do;
           occupationId = 5; /*<- pracownicy lotnisk */
          %end; 
         %end;
      %end;
   output;
  %end;
 stop;
 run;


%mend generujPracownikow;


%generujPracownikow(1000, danepro.nazwiska, danepro.imiona, danepro.occupations, pracownicy=danepro.employees)




/*----------------Generowanie danych o polaczeniach lotniczych------------------------------*/

%macro generujPolaczenia(lotniska,zbiorPolaczen=);
 
  %if %datasetExists(&lotniska.) %then 
  %do; 
   %return; 
  %end;
  
  options cmplib = (funk.funkcje _DISPLAYLOC_);
  
 data &zbiorPolaczen.;
  set &lotniska.(keep=airportID latitude longitude rename=(airportID=departureAirportId latitude=depatureLatitude longitude=departureLongitude)) nobs=n;
  do i = 1 to n;
    set &lotniska.(keep=airportID latitude longitude rename=(airportID=destinationAirportId latitude=destinationLatitude longitude=destinationLongitude)) point=i;
     if departureAirportId ~= destinationAirportId then
      do
       trackLength = round(obliczOdleglosc(depatureLatitude,departureLongitude, destinationLatitude,destinationLongitude ));
       expectedFlightTime = round(trackLength/800, 0.01);
       output;
   	  end;
  end;
 
  keep departureAirportId destinationAirportId trackLength expectedFlightTime;
 
 run;

  
  options cmplib = _null_;

%mend generujPolaczenia;


%generujPolaczenia(danepro.airports, zbiorPolaczen=danepro.tracks)




/*----------------Generowanie danych o aktywnosci samolotow------------------------------*/

%macro generujAktywnoscSamolotow(samoloty, dataRozpoczecia, lotniska,trasy, startAirportId, klienci, modeleSamolotow);


 /* sprawdzenie czy zbiory istnieja */

  %if %datasetExists(&samoloty.) %then 
  %do; 
   %return; 
  %end;

  %if %datasetExists(&lotniska.) %then 
  %do; 
   %return; 
  %end;

  %if %datasetExists(&trasy.) %then 
  %do; 
   %return; 
  %end;

  %if %datasetExists(&klienci.) %then 
  %do; 
   %return; 
  %end;

  %if %datasetExists(&modeleSamolotow.) %then 
  %do; 
   %return; 
  %end;

 /* przyisanie makrozmiennej liczbaTras liczbe dostepnych tras*/
 /* z zbioru danych trasy */
 %let dsid=%sysfunc(OPEN(&lotniska.,in));
 %let liczbaLotnisk=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.));
 
 options cmplib=(funk.funkcje _DISPLAYLOC_);
 
 data danepro.flights(keep=planeId flightId trackLength departureAirportId destinationAirportId flightTime departureDate arrivalDate)
 danepro.flightLog(keep=flightId log logDate)
 danepro.repairHistory(keep=repairId planeId startRepairDate endRepairDate typeId);
 
 if 0 then set &trasy.;
 
 if _n_ = 1 then 
 do;
  flightId=0;
  startDate = "&dataRozpoczecia."d;
  endDate = today();
  array idPopularnychLotnisk[12] _temporary_ (3,4,9,10,21,25,28,36,40,45,47, &startAirportId.);
  
  declare hash trasy(dataset: "&trasy.");
  trasy.DefineKey('destinationAirportId', 'departureAirportId');
  trasy.DefineData("trackLength","expectedFlightTime");
  trasy.DefineDone();
  
  repairId = 0;
  
 end;
 
 set &samoloty.;
 where status='active';
 
 startHour = floor(rand('UNIFORM',0,24));
 
 date = startDate;
 hour = startHour;
 departureAirportId = &startAirportId.;
 
 do until(date >= endDate); /* <- generowanie trwa od startDate do dnia dzisiejszego */
  
 repair=0;
  
  u = rand("UNIFORM");
  
  if u <= 0.6 then
   do;
    
    pointer = ceil(rand("UNIFORM",0,dim(idPopularnychLotnisk)));
    
    destinationAirportId = idPopularnychLotnisk[pointer];
    
   end;
  else if u <= 0.8 then
   do;
   	destinationAirportId = &startAirportId.;
   end;
  else
   do;
    
    destinationAirportId=ceil(rand("UNIFORM",0,&liczbaLotnisk.));
    
   end;
  
  if departureAirportId = destinationAirportId then continue;
  
   flightId = flightId+1;
   rc=trasy.find();
   
   u = rand("UNIFORM");
   IF u <= 0.9 then flightTime= round(expectedFlightTime + rand("NORMal",0,0.1),0.01);
   else flightTime= round(expectedFlightTime + 4*rand("BETA",4,2), 0.01);
    
    
    departureDate = dhms(date, hour,0,0);
    
	/*Obliczenie daty i godziny przylotu*/
	
	arrivalDate = obliczDate(date,hour, flightTime);
	 
	/*---------------Wypisanie do loga informacji--------------------------*/
	
	length log $ 200;
	log = 'The aircraft number '||strip(planeId)||' has departured from airport number '||strip(departureAirportId)|| ' to airport number '||strip(destinationAirportId)||' at '|| strip(putn(departureDate,"datetime19."))||'.';
    logDate = departureDate;
    output danepro.flightLog;
    
	/* Mozliwe zaklocenia lotu */
	
	numberOfAccidents = floor(5*rand('BETA',2.5,11));
	
	if numberOfAccidents > 0 then 
	 do;
	  do i = 1 to numberOfAccidents;
	   
	   hourOfAccident = round(rand("Uniform", 0.05, flightTime-0.05),0.01); 
	   uu = rand("UNIFORM");
	  
	  
	   if uu <= 0.97 then 
	    do;
	     log = 'The aircraft number '||strip(planeId)||' just experienced turbulence';
	     uuu = rand('UNIFORM', 0, 1);
	     if uuu > 0.99 then repair = 1; else repair=0;
	    end;
	   else if uu <= 0.995 then 
	    do; 
	     log = 'A flock of geese just collided with the aircraft number '||strip(planeId)||'.';
	     repair=1;
	    end;
	   else 
	    do;
	     log = 'One of the engines of aircraft number '||strip(planeId)||' has just exploded.';
	     repair=1;
	    end;
	    
	   logDate = obliczDate(date, hour, hourOfAccident);
	  
	   output danepro.flightLog;
	  
	  end;
	 
     /*Skoro wystapily powazne zaklocenia to oddajemy samolot do naprawy */
    if repair then 
     do;
	  repairTime = floor(rand('BETA',2,5)*14 +1);
	  typeId = ceil(rand('BETA',2,5)*5);
	 
	  startRepairDate=datepart(arrivalDate);
	  endRepairDate = startRepairDate + repairTime;	 
	 
	  repairId = repairId+1;
	 	 
	  output danepro.repairHistory;
	 end;
	  
	  
	 end;
    
    
    log = 'The aircraft number '||strip(planeId)||' has landed at the airport number '||strip(destinationAirportId)||' at '|| strip(putn(departureDate,"datetime19."))||'.';
    logDate = arrivalDate;
    output danepro.flightLog;
    
    /*---------------koniec wypisania do loga informacji--------------------------*/
    
 	output danepro.flights; /* <- wypisanie informacji o locie */
 	
    /*Zaktulizowanie zmiennych do nastepnej petli */
   
   if repair then 
    do;
     date = endRepairDate+1;
     hour = floor(rand('BETA',2,5)*24);
    end;
   else
    do;
    
    restTime = floor(rand('UNIFORM',2,9));
    dTemp=obliczDate(date, hour+flightTime, restTime);
    date = datepart(dTemp);
    hour = hour(dTemp);
    end;
    
    repair = 0;


 	departureAirportId = destinationAirportId;
 	 	
 
 end;
 
 retain startDate endDate;
  
 format date startRepairDate endRepairDate ddmmyy10. logdate departureDate arrivalDate arrivalDate1 datetime19.;
 retain flightId startDate startHour repairId;
 
 run;
 
 options cmplib=_null_;
 
 
/* Teraz aby dane mialy wiecej sensu musimy posortowac je po dacie  */
/* wylotu oraz zapewnic poprawnosc chronologiczna flightId */

 proc sort data=danepro.flights;
  by departureDate;
 run;
 
 data chronologiczneFlightId;
 
  set danepro.flights;
  nr = _n_;
  output;
  keep nr flightId departureDate;
 run;
 
 proc sort data=danepro.flights;
  by flightId;
 run;

 proc sort data=chronologiczneFlightId;
  by flightId;
 run;
 
 data danepro.flights;
  merge danepro.flights chronologiczneFlightId;
   by flightId;
   flightId = nr;
   output;
   
  drop nr;
 run;

 data danepro.flightLog;
  merge danepro.flightLog chronologiczneFlightId;
   by flightId;
   flightId = nr;
   output;
   
  drop nr;
 run;
 

 proc sort data=danepro.flights;
  by flightId;
 run;
 
 proc sort data=danepro.flightLog;
  by logDate;
 run;
 
 proc sort data=danepro.repairHistory;
  by startRepairDate;
 run;
 
 
 /* generowanie klientow i pracownikow polaczen */

 data tempPiloci;
  set danepro.employees;
   where occupationId = 2;
  i= _n_;
  output;
 run;
 
 /* przyisanie makrozmiennej liczbaPilotow liczbe pilotow  */
 /* z zbioru danych pracownikow */
 %let dsid=%sysfunc(OPEN(tempPiloci,in));
 %let liczbaPilotow=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.));
 
 
 data tempStewardesi;
 set danepro.employees;
 where occupationId = 3;
   i= _n_;
  output;
 run;
 
 /* przyisanie makrozmiennej liczbaStewardesow liczbe Stewardesow */
 /* z zbioru danych pracownikow */
 %let dsid=%sysfunc(OPEN(tempStewardesi,in));
 %let liczbaStewardesow=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.));
 

 data danepro.flightService(keep=employeeId flightId);
 
 if 0 then set tempStewardesi tempPiloci;
 
 if _N_ = 1 then 
  do;
   
   declare hash stewardesi(dataset: "tempStewardesi");
   stewardesi.DefineKey('i');
   stewardesi.DefineData("employeeId");
   stewardesi.DefineDone();
   
   declare hash piloci(dataset: "tempPiloci");
   piloci.DefineKey('i');
   piloci.DefineData("employeeId");
   piloci.DefineDone();
   
   array idPilotow[&liczbaPilotow.] _temporary_;   
   array idLotniskoPilot [&liczbaPilotow.] _temporary_;
   array dostepnoscPilota[&liczbaPilotow.] _temporary_;
   
   array idStewardesow[&liczbaStewardesow.] _temporary_;   
   array idLotniskoSteward[&liczbaStewardesow.] _temporary_;
   array dostepnoscStewarda[&liczbaStewardesow.] _temporary_;

  sDate = "&dataRozpoczecia."d;
  
  do i = 1 to &liczbaPilotow.;
   rc = piloci.find();
   idPilotow[i] = employeeId;
   dostepnoscPilota[i] = dhms(sDate-1,0,0,0);
   if i <= 100 then 
    do;
     idLotniskoPilot[i] = 1;
    end;
   else if i <= 150 then
    do;
     idLotniskoPilot[i] = i - 100;
    end;
   else if i <= 200 then
    do;
     idLotniskoPilot[i] = i - 150;
    end;
   else 
    do;
     idLotniskoPilot[i] = ceil(rand('UNIFORM', 0, 50));
    end;
  end;
  
  
  do i = 1 to &liczbaStewardesow.;
   
   rc = stewardesi.find();
   idStewardesow[i] = employeeId;
   dostepnoscStewarda[i] = dhms(sDate-1,0,0,0);
   
   if i <= 100 then 
    do;
     idLotniskoSteward[i] = 1;
    end;
   else if i <= 150 then
    do;
     idLotniskoSteward[i] = i - 100;
    end;
   else if i <= 200 then
    do;
     idLotniskoSteward[i] = i - 150;
    end;
   else 
    do;
     idLotniskoSteward[i] = ceil(rand('UNIFORM', 0, 50));
    end;
  end;
  
  end;
  
  set danepro.flights;
  
  /*przyporzadkowanie pilotow do lotow */
  count=0;
  do i = 1 to &liczbaPilotow.;
   if idLotniskoPilot[i] = departureAirportId and dostepnoscPilota[i] < departureDate then 
    do;
     employeeId = idPilotow[i];
     
     output;
     idLotniskoPilot[i] = destinationAirportId;
     dostepnoscPilota[i] = arrivalDate + 3600;
     count = count + 1;
     if count = 2 then leave;
    end;
  end;

 /*przyporzadkowanie stewardesow do lotow */
  count=0;
  do i = 1 to &liczbaStewardesow.;
   if idLotniskoSteward[i] = departureAirportId and dostepnoscStewarda[i] < departureDate then 
    do;
     employeeId = idStewardesow[i];
     output;
     idLotniskoSteward[i] = destinationAirportId;
     dostepnoscStewarda[i] = arrivalDate + 3600;
     count = count + 1;
     if count = 2 then leave;
    end;
  end;
  
 run;


 /*przypisanie lotom pasazerow */

 /* przyisanie makrozmiennej liczbaKlientow liczbe klientow  */
 /* z zbioru danych klientow */
 %let dsid=%sysfunc(OPEN(&klienci.,in));
 %let liczbaKlientow=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.));
 
 data tempKlienci;
  set &klienci.;
  i = _n_;
  output;
  keep customerId i;
 run;
 
 
 /* przyisanie makrozmiennej liczbaSamolotow liczbe samolotow  */
 /* z zbioru danych samolotow */
 %let dsid=%sysfunc(OPEN(&samoloty.,in));
 %let liczbaSamolotow=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.));
 
  data tempSamoloty;
  set &samoloty.;
  i = _n_;
  output;
  keep planeId modelId i;
 run;
 
 
  /* przyisanie makrozmiennej liczbaModeli liczbe modeli  */
 /* z zbioru danych modeli samolotow */
 %let dsid=%sysfunc(OPEN(&modeleSamolotow.,in));
 %let liczbaModeli=%sysfunc(ATTRN(&dsid.,nobs));
 %let rc=%sysfunc(CLOSE(&dsid.));
 
   data tempModele;
  set &modeleSamolotow.;
  i = _n_;
  output;
  keep category numberOfSeats modelId i;
 run;
 
 
 data danepro.flightReservations(keep=customerId flightId status seatNumber class paymentId) 
 danepro.payments(keep=paymentId payment)
 ;
 
 if 0 then set tempKlienci tempSamoloty tempModele;
 
 if _N_ = 1 then 
  do;
   
   /*tablice z danymi o klientach*/
  
   declare hash klienci(dataset: "tempKlienci");
   klienci.DefineKey('i');
   klienci.DefineData("customerId");
   klienci.DefineDone();
    
   array idKlient[&liczbaKlientow.] _temporary_;   
   array idKlientZajety[&liczbaKlientow.] _temporary_;
   
   do i = 1 to &liczbaKlientow.;
    rc = klienci.find();
    idKlient[i] = customerId;
   end;
  
   /*tablice z danymi o samolotach*/
  
   declare hash samoloty(dataset: "tempSamoloty");
   samoloty.DefineKey('i');
   samoloty.DefineData("planeId", 'modelId');
   samoloty.DefineDone();
    
   array idSamolot[&liczbaSamolotow.] _temporary_;   
   array idModeluSamolotu[&liczbaSamolotow.] _temporary_;
   
   do i = 1 to &liczbaSamolotow.;
    rc = samoloty.find();
    idSamolot[i] = planeId;
    idModeluSamolotu[i] = modelId;
   end;

   /*tablice z danymi o modelach samolotow*/
  
   declare hash modele(dataset: "tempModele");
   modele.DefineKey('i');
   modele.DefineData("numberOfSeats", 'modelId', 'category');
   modele.DefineDone();
    
   array idModelu[&liczbaModeli.] _temporary_;   
   array pojemnoscModelu[&liczbaModeli.] _temporary_;
   array rozmiarModelu[&liczbaModeli.] $ _temporary_ ;
   
   do i = 1 to &liczbaModeli.;
    rc = modele.find();
    idModelu[i] = modelId;
    pojemnoscModelu[i] = numberOfSeats;
    rozmiarModelu[i] = category;
   end;

  end;
  
  
  set danepro.flights;
  
  if _n_ = 1 then paymentId=1;
  
  do i = 1 to &liczbaSamolotow.;
   
   if idSamolot[i] = planeId then 
    do;
     
     modelId = idModeluSamolotu[i];
     do j = 1 to &liczbaModeli.;
     
     if modelId = idModelu[j] then 
       do;
        rozmiarSamolotu = rozmiarModelu[j];
        pojemnoscSamolotu = pojemnoscModelu[j];
        leave;
       end;
     end;
     leave;
    end;
  end;
  
  liczbaMiejscDoRezerwacji =pojemnoscSamolotu + floor(pojemnoscSamolotu*0.05);
  
  do i = 1 to liczbaMiejscDoRezerwacji;
   do j = 1 to 10;
    indexKlienta = ceil(rand("UNIFORM", 0, &liczbaKlientow.));
    if idKlientZajety[indexKlienta] < departureDate then 
     do;
      customerId = idKlient[indexKlienta];
      idKlientZajety[indexKlienta] = arrivalDate + 86400; /* <- liczba sekund w jednym dniu */
      leave;
     end;
    end;
     if customerId=. then continue;
     
     seatNumber = i;
     length class $ 6;
     if i <= 0.1*liczbaMiejscDoRezerwacji then class  ='first';
     else if i <= 0.4*liczbaMiejscDoRezerwacji then class  ='second';
     else class  ='third';
     
     u = rand("UNIFORM");
     if u <= 0.95 then status=1;
     else status=0;
     
     fullPayment = trackLength*0.1 + ceil(rand("Uniform",0,100));
     
     /* przeliczniki za klase biletu */
     if class = 'first' then classBonus =5;
     else if class = 'second' then classBonus =1.2;
     else classBonus = 0.8;
     
     /* przeliczniki za rozmiar samolotu */
     
     if rozmiarSamolotu = 'small' then planeBonus =3;
     else if rozmiarSamolotu = 'medium' then planeBonus =2;
     else planeBonus =1;
     
     payment = round(fullPayment*classBonus*planeBonus,0.01);
     
     output;
     paymentId=paymentId+1;
     customerId=.;
     

  end;
  
  
  retain paymentId;
 
 run;


%mend generujAktywnoscSamolotow;

%generujAktywnoscSamolotow(danepro.planes, 20FEB2025, danepro.airports,danepro.tracks ,1, danepro.customers, danepro.aircraftsmodels)




