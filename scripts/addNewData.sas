/*podlaczenie biblioteki */
libname danepro
base
'/home/u63796376/daneProjekt';

/*--------------dodawanie jednego klienta---------------------------------*/

%macro dodajKlienta(imie=,nazwisko=, email=, phoneNumber=, birthdate=,loyaltyLevel=,countryId=);

%local maxId;

proc sql noprint;
   select max(customerId)
   into :maxId
   from danepro.customers;
quit;



 data __temp__;
 
  if 0 then set danepro.customers;
 
  customerId= %eval(&maxId. + 1);
  firstname = "&imie.";
  lastname = "&nazwisko.";
  email = "&email.";
  phoneNumber = &phoneNumber.;
  countryId = &countryId.;
  loyaltyLevel = "&loyaltyLevel.";
 run;
 
 proc append base=danepro.customers data=__temp__;run;
 
 proc delete data=WORK.__temp__; run;
 
 
 
%mend dodajKlienta;


/*--------------dodawanie jednego lub wiecej klientow---------------------------------*/


%macro dodajKlientow(klienci);
  
  %if %datasetExists(&klienci.) %then 
  %do; 
   %return; 
  %end;
  
 /* sprawdzenie czy odpowiednie zmienne istnieją w zbiorze klienci */
 %if %eval(not(%varexist(&klienci., firstname))) or %eval(not(%varexist(&klienci., lastname)))
 or %eval(not(%varexist(&klienci., email))) or %eval(not(%varexist(&klienci., phoneNumber)))
 or %eval(not(%varexist(&klienci., countryId))) or %eval(not(%varexist(&klienci., loyaltyLevel))) %then 
  %do;
   %put W zbiorze &klienci. muszą się znaleźć zmienne: firstname, lastname, email, phoneNumber, countryId, loyaltyLevel;
   %return;
  %end;
  
 %local maxId;

 proc sql noprint;
   select max(customerId)
   into :maxId
   from danepro.customers;
 quit;
  
 data __temp__;
 
 if 0 then set danepro.customers;

 %if %varexist(&klienci., birthdate) %then
 set &klienci.(keep = firstname lastname email phoneNumber countryId loyaltyLevel birthdate);
 %else set &klienci.(keep = firstname lastname email phoneNumber countryId loyaltyLevel); 
 ;
 customerId = &maxId. + _n_;
 output;
 
 run;
 
 proc append base=danepro.customers data=__temp__;run;
 
 proc delete data=WORK.__temp__; run;


%mend dodajKlientow;




/*--------------dodawanie jednego pracownika---------------------------------*/


%macro dodajPracownika(imie=,nazwisko=, pozycja=);

 %local maxId occupationId;
 
 %let occupationId = 0;

 proc sql noprint;
   select max(employeeId)
   into :maxId
   from danepro.employees;
   
   select occupationId
   into: occupationId
   from danepro.occupations
   where occupation = "&pozycja.";
 quit;

 %if %eval(not(&occupationId.)) %then %do; %put Nie ma takiej pozycji - "&pozycja." w naszej firmie, obserwacja nie została dodana; %return; %end;

 data __temp__;
 
  if 0 then set danepro.employees;
 
  employeeId= %eval(&maxId. + 1);
  firstname = "&imie.";
  lastname = "&nazwisko.";
  occupationId = &occupationId.;
 run;
 
 proc append base=danepro.employees data=__temp__;run;
 
 proc delete data=WORK.__temp__; run;
 
%mend dodajPracownika;


/*--------------dodawanie jednego samolotu---------------------------------*/

%macro dodajSamolot(modelSamolotu=, rokProdukcji=);

 %local maxId modelId;
 
 %let modelId = 0;

 proc sql noprint;
   select max(planeId)
   into :maxId
   from danepro.planes;
   
   select modelId
   into: modelId
   from danepro.aircraftsModels
   where aircraftModel = "&modelSamolotu.";
 quit;

 %if %eval(not(&modelId.)) %then %do; %put Nie istnieje model samolotu - "&modelSamolotu.", obserwacja nie została dodana; %return; %end;

 data __temp__;
 
  if 0 then set danepro.planes;
 
  planeId= %eval(&maxId. + 1);
  modelId = &modelId.;
  productionYear = &rokProdukcji.;
  status='active';
 run;
 
 proc append base=danepro.planes data=__temp__;run;
 
 proc delete data=WORK.__temp__; run;
 
%mend dodajSamolot;
/*--------------dodawanie jednego lotniska---------------------------------*/

%macro dodajLotnisko(nazwa=, miasto=, kodLotniska=, kraj=, latitude=, longitude=);

 %local maxId countryId czyNowe;
 
 %let czyNowe = 0;
 %let countryId=0;

 proc sql noprint;
   select max(airportId)
   into :maxId
   from danepro.airports;
   
   select count(airportCode)
   into: czyNowe
   from danepro.airports
   where airportCode = "&kodLotniska.";
   
   select countryId
   into: countryId
   from danepro.countries
   where country = "&kraj.";
 quit;
 

 %if %eval(not(&countryId.)) %then %do; %put Nie istnieje kraj - "&kraj.", obserwacja nie została dodana; %return; %end;
 %if &czyNowe. %then %do; %put Już istnieje lotnisko o kodzie - "&kodLotniska.", obserwacja nie została dodana; %return; %end;


 data __temp__;
 
  if 0 then set danepro.airports;
 
  airportId= %eval(&maxId. + 1);
  name = "&nazwa.";
  city = "&miasto.";
  airportCode = "&kodLotniska.";
  countryId = &countryId.;
  latitude = &latitude.;
  longitude = &longitude.;
 run;
 
 proc append base=danepro.airports data=__temp__;run;
 
 proc delete data=WORK.__temp__; run;
 
%mend dodajLotnisko;

/*--------------dodawanie samolotu do naprawy---------------------------------*/

%macro samolotDoNaprawy(samolotId=, typUsterki=, dataRozpoczecia=, dataKonca=);
 
 %local maxId typeId czyJuzWNaprawie;
 
 %let czyJuzWNaprawie = 0;
 %let typeId=0;

 proc sql noprint;
   select max(repairId)
   into :maxId
   from danepro.repairHistory;
   
   select count(planeId)
   into: czyJuzWNaprawie
   from danepro.repairHistory
   where planeId = &samolotId. and EndRepairDate > "&dataRozpoczecia."d;
   
   select typeId
   into: typeId
   from danepro.repairTypes
   where name = "&typUsterki.";
 quit;

 %if %eval(not(&typeId.)) %then %do; %put Nie naprawiamy usterki - "&typUsterki.", obserwacja nie została dodana; %return; %end;
 %if &czyJuzWNaprawie. %then %do; %put Samolot o nr &samolotId. jest już w naprawie, obserwacja nie została dodana; %return; %end;
 
 data __temp__;
 
  if 0 then set danepro.repairHistory;
 
  repairId= %eval(&maxId. + 1);
  planeId = "&samolotId.";
  typeId = "&typeId.";
  startRepairDate = "&dataRozpoczecia."d;
  EndRepairDate = "&dataKonca."d;
 run;
 
 proc append base=danepro.repairHistory data=__temp__;run;
 
 proc delete data=WORK.__temp__; run;

%mend samolotDoNaprawy;


/*---------------------dodawanie lotu--------------------------------------------*/

%macro dodajLot(miastoWylotu=, miastoPrzylotu=, dataWylotu=);

 /*zamiana miasta na id lotniska znajdującego sie w nim */

 %local depAirportId destAirportId;
 %let depAirportId=0;
 %let destAirportId=0;

 proc sql noprint;
  
  select airportId
  into :depAirportId
  from danepro.airports
  where city = "&miastoWylotu.";
  
    select airportId
  into :destAirportId
  from danepro.airports
  where city = "&miastoPrzylotu.";
 quit;

 %if %eval(not(&depAirportId.)) %then %do; %put Nie latamy z miasta - "&miastoWylotu.", obserwacja nie została dodana; %return; %end;

 %if %eval(not(&destAirportId.)) %then %do; %put Nie latamy do miasta - "&miastoPrzylotu.", obserwacja nie została dodana; %return; %end;



 /* wybranie samolotow na miejscu  */
 proc sql noprint;
 create table samolotyNaMiejscu as 
   (select x.planeId, y.airportId, x.arrivalDate from
   ((select planeId, destinationAirportId, arrivalDate
   from danepro.flights
   group by planeId
   having arrivalDate = max(arrivalDate)) as x 
   join 
   (select city, airportId from danepro.airports) as y
   on x.destinationAirportId = y.airportId)
   where y.city = "&miastoWylotu." and x.arrivalDate<"&dataWylotu."dt);
 quit;
 
 /*sprawdzenie czy mamy jakies samoloty na miejscu  */
 proc contents noprint data = samolotyNaMiejscu OUT = OUT(keep=nobs); run;

 data _NULL_;
  set OUT(obs=1);
  call symputx('liczbaSamolotowNaMiejscu',nobs);
  stop;
 run;
 
 %if %eval(not(&liczbaSamolotowNaMiejscu.)) %then 
  %do;
   %put Nie możemy zrealizować połączenia - w tej chwili nie ma żadnych samolotów na miejscu :(;
   %return;
  %end;

 /* losowy wybor samolotu z tych dostepnych na miejscu */

 data _null_;
 
 wybor = ceil(rand('UNIFORM',0,&liczbaSamolotowNaMiejscu.));
 
 
 set samolotyNaMiejscu point=wybor;
 call symputx('planeId', planeId);
 STOP;
 
 run;
 
 /* wybranie zalogi na miejscu  */

 proc sql noprint;
 create table zalogaNaMiejscu as 
 select etf2.employeeId, etf2.destinationAirportId, etf2.arrivalDate
 from
  (select etf.employeeId, etf.destinationAirportId, etf.arrivalDate from
   (select x.flightId,x.destinationAirportId,x.arrivalDate, y.employeeId 
    from
   ((select flightId, destinationAirportId, arrivalDate
   from danepro.flights) as x
   join 
   (select employeeId, flightId from danepro.flightservice) as y
   on x.flightId = y.flightId)
   ) as etf
   group by etf.employeeId
   having etf.arrivalDate = max(etf.arrivalDate)) as etf2
   where etf2.destinationAirportId =&depAirportId. and etf2.arrivalDate < "&dataWylotu."dt;
 quit;
 
 
/*sprawdzenie czy mamy jakiekolwiek osoby na miejscu  */
 proc contents noprint data = zalogaNaMiejscu OUT = OUT(keep=nobs); run;

 data _NULL_;
  set OUT(obs=1);
  call symputx('liczbaOsobNaMiejscu',nobs);
  stop;
 run;
 
 %if %eval(not(&liczbaOsobNaMiejscu.)) %then 
  %do;
   %put Nie możemy zrealizować połączenia - w tej chwili nie ma żadnych pracowników na miejscu :(;
   %return;
  %end;
 
 /*sprawdzenie czy na miejscu znajduje sie przynajmniej po 2 stewardesow i po 2 pilotow*/

 proc sql noprint;
  create table pozycjaObecnychNaMiejscu as(
   select o.occupation, znm.*  from
    danepro.employees as e 
    inner join
    zalogaNaMiejscu as znm on e.employeeId = znm.employeeId
    join
    danepro.occupations as o on o.occupationId = e.occupationId
  );
 quit;
 
 %local nieMa;
 %let nieMa = 0;
 
 data _null_;
 
  if _n_ =1 then 
   do;
    array piloci[&liczbaOsobNaMiejscu.] _temporary_;
    array stewardesi[&liczbaOsobNaMiejscu.] _temporary_;   
    liczbaPilotow=0;
    liczbaStewardow=0;
   end;
   
  set pozycjaObecnychNaMiejscu end=e;
  
  if occupation = 'Flight Attendant' then 
   do;
    stewardesi[liczbaStewardow+1] = employeeId;
    liczbaStewardow= liczbaStewardow+1;
   end;
   
   
  else if occupation = 'Pilot' then 
   do;
    piloci[liczbaPilotow+1] = employeeId;
    liczbaPilotow= liczbaPilotow+1;
   end;
   
   
  if e then 
   do;
    if liczbaPilotow >= 2 and liczbaStewardow >= 2 then 
     do;
      tmp = 1;
      u1 = ceil(rand("UNIFORM", 0, liczbaPilotow));
      do while(1);
       u2 = ceil(rand("UNIFORM", 0, liczbaPilotow));
       if u1 ~= u2 then leave;
      end;
      
      call symputx('pilot1', piloci[u1]);
      call symputx('pilot2', piloci[u2]);
      
      u1 = ceil(rand("UNIFORM", 0, liczbaStewardow));
      do while(1);
       u2 = ceil(rand("UNIFORM", 0, liczbaStewardow));
       if u1 ~= u2 then leave;
      end;
      
      call symputx('steward1', stewardesi[u1]);
      call symputx('steward2', stewardesi[u2]);
      
      
     end;
   else call symputx('nieMa', 1);
  
   end;
   
  retain liczbaPilotow liczbaStewardow;
    
 run;

 %if %eval(&nieMa.) %then %do;%put Nie mamy wystarczajaco pilotow lub stewardow na miejscu, obserwacja nie zostanie dodana; %return;%end;
  
  %local maxId;

/* wyciagniecie ostatniego id lotu */

  proc sql noprint;
   select max(flightId)
   into :maxId
   from danepro.flights;

 /* wyciagniecie wspolrzednych geograficznych z obydwu lotnisk */

   select latitude, longitude
   into :depLat, :depLong
   from danepro.airports
   where airportId = &depAirportId.;
 
   select latitude, longitude
   into :destLat, :destLong
   from danepro.airports
   where airportId = &destAirportId.;
 
 /* wyciagniecie informacji o dlugosci i czasie lotow */

   select trackLength, expectedFlightTime
   into :trackLength, :expectedFlightTime
   from danepro.tracks
   where departureAirportId = &depAirportId. and destinationAirportId=&destAirportId.;
 
 quit;
 
 options cmplib = (funk.funkcje _DISPLAYLOC_);

 data __temp__;
 
  drop expectedFlightTime;
 
  if 0 then set danepro.flights;
  
  flightId = %eval(&maxId.+1);
  planeId = &planeId.;
  departureAirportId =&depAirportId;
  destinationAirportId = &destAirportId;
  departureDate="&dataWylotu."dt;
  expectedFlightTime = &expectedFlightTime.;
  expectedFlightTime = expectedFlightTime + rand('NORMal',0 , 0.1);
  flightTime = round(expectedFlightTime,0.01);
  trackLength = &trackLength.;
  arrivalDate = departureDate + flightTime*3600;
 run;

 options cmplib = _null_;
 
 proc append base=danepro.flights data=__temp__;run;
 proc delete data=WORK.__temp__; run;
 
  data __temp__;
 
   if 0 then set danepro.flightservice;
  
   flightId = %eval(&maxId.+1);
   
   employeeId = &pilot1.;
   output;
   employeeId = &pilot2.;
   output;
   employeeId = &steward1.;
   output;  
   employeeId = &steward2.;
   output; 
 run;
 
 proc append base=danepro.flightservice data=__temp__;run;
 proc delete data=WORK.__temp__; run;
 
  
 /*usuniecie pozostalych zbiorow pomocniczych */
 proc delete data=WORK.pozycjaObecnychNaMiejscu; run;
 proc delete data=WORK.zalogaNaMiejscu; run;
 proc delete data=WORK.samolotyNaMiejscu; run;
 proc delete data=WORK.OUT; run;
 
 %put Lot zostal pomyslnie dodany;

%mend dodajLot;


/*--------------dodawanie pasazerow do lotu---------------------------------*/

%macro dodajPasazera(idPasazera, idLotu, klasa);

 %local customerId;
 %let customerId = 0;

 data _null_;
  
  set danepro.customers;
  where customerId = &idPasazera.;
  call symputx('customerId',customerId);
 
 run;
 
  %if %eval(not(&customerId.)) %then %do; %put Nie istnieje klient o numerze - "&idPasazera.", obserwacja nie została dodana; %return; %end;

 %local flightId;
 %let flightId = 0;

 data _null_;
  
  set danepro.flights;
  where flightId = &idLotu.;
  call symputx('flightId',flightId);
  call symputx('planeId',planeId); 
  call symputx('trackLength', trackLength);
 
 run;
 
  %if %eval(not(&flightId.)) %then %do; %put Nie istnieje lot o numerze - "&idLotu.", obserwacja nie została dodana; %return; %end;


 data _null_;
 
  set danepro.flightreservations end=e;
  where flightId = &idLotu.;
  
  if _n_=1 then licznik=0;
  
  licznik=licznik+1;
  
  if e then 
   do;
    call symputx('liczbaRezerwacji',licznik);
    put licznik;
   end;
 retain licznik;
 run;
 
 data _null_;
  set danepro.planes;
   where planeId = &planeId.;
  
   call symputx('modelId',modelId);
 run;
 
 data _null_;
  set danepro.aircraftsmodels;
   where modelId = &modelId.;
 
 call symputx('maxLiczbaRezerwacji',numberOfSeats);
 call symputx('rozmiarSamolotu', category);
 run;
 
 %if %sysevalf(%sysevalf(1.1*&maxLiczbaRezerwacji.) < &liczbaRezerwacji.) %then 
  %do;
   %put Na ten samolot nie ma już miejsc, obserwacja nie zostanie dodana;
   %return;
  %end;
  
  
proc sql noprint;
   select max(paymentId)
   into :maxId
   from danepro.payments;

quit;
  
 
 
 data __temp__;
 drop maxLiczbaRezerwacji;
 if 0 then set danepro.flightreservations;
 
  customerId = &idPasazera;
  paymentId = %eval(&maxId. + 1);
  flightId = &idLotu.;
  maxLiczbaRezerwacji = &maxLiczbaRezerwacji.;
  seatNumber = floor(rand("UNIFORM")*maxLiczbaRezerwacji);
  class = "&klasa.";
  status=.;
 run;

 proc append base=danepro.flightreservations data=__temp__;run;
 
 proc delete data=WORK.__temp__; run;S
 
  
 data __temp__;
 
 if 0 then set danepro.payments;
 
 keep paymentId payment;
 
  paymentId = %eval(&maxId. + 1);
  class = "&klasa.";
  rozmiarSamolotu = "&rozmiarSamolotu.";

	trackLength = &trackLength.;
    
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

 run;
 
 proc append base=danepro.payments data=__temp__;run;
 
 proc delete data=WORK.__temp__; run;

%mend dodajPasazera;
