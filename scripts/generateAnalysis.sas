/* 1. Podsumowanie lotu */

%macro podsumujLot(idLotu=);

 Title1  height=50pt "Podsumowanie lotu numer &idLotu.";
 
  data _null_;
  set danepro.employees;
   where employeeId = 1;
  
  sformatowanaPozycja = put(occupationId, occupations.);
   
  call symputx('imiePracownika', firstname);
  call symputx('nazwiskoPracownika', lastname);
  call symputx('pozycja', sformatowanaPozycja);
  
 run;



 data _null_;
  set danepro.flights;
   where flightId = &idLotu.;
   call symputx('planeId', planeId);
   call symputx('depAirportId', departureAirportId);
   call symputx('destAirportId',destinationAirportId);
 run;
 
  data _null_;
  set danepro.planes;
   where planeId = &planeId.;
  call symputx('modelId', modelId);
  call symputx('category', category);
 run;
 
 
 data _null_;
  set danepro.aircraftsmodels;
   where modelId = &modelId.;
  call symputx('producerId', producerId);
 run;
 
 data __temp__;
  planeId = &planeId.;
  modelId = &modelId.;
  producerId = &producerId.;
  label planeId = 'Numer Samolotu' modelId = 'Model Samolotu' producerId='Producent Samolotu';
 run;
 
 proc print data=__temp__ label;
 title1 height=25pt 'Lot wykonał następujący samolot';
 format modelId models. producerId producers.;
 label planeId = 'Numer Samolotu' modelId = 'Model Samolotu' producerId='Producent Samolotu';

 run;
 
 options cmplib = (funk.funkcje _DISPLAYLOC_);

 data flightsTemp;
  set danepro.flights;
   where flightId = &idLotu.;
   emission = round(obliczWydaloneCO2(trackLength, category),0.01);
   output;
 run;
 
 options cmplib = _null_;

 
 proc print data=flightsTemp label; 
 label departureAirportId='Lotnisko Startowe' destinationAirportId='Lotnisko Końcowe' departureDate = 'Data Wylotu' arrivalDate='Data Przylotu'
 trackLength = 'Długość trasy (km)' emission='Emisja CO2';
 title1 height=25pt "Informacje o locie nr &idLotu.";
 var departureAirportId destinationAirportId trackLength departureDate arrivalDate emission;

 format departureAirportId destinationAirportId airportName.;
 run;


 data __temp__;
  set danepro.flightService;
   where flightId = &idLotu.;
 run;
 
 proc sql noprint;
  create table __temp2__ as
  select e.*
  from
   danepro.employees as e 
   join 
   __temp__ as t
   on e.employeeId = t.employeeId;
 run;
 
 proc print data = __temp2__ label;
  title1 height=25pt "Informacje o załodze lotu nr &idLotu.";
 label occupationId='Rola' lastname='Nazwisko' firstname='Imię';
 var firstname lastname occupationId;
 format occupationId occupations.;
 
 run;
 
 data __temp__;
  set danepro.flightReservations;
   where flightId = &idLotu.;
 run;
 
  proc sql noprint;
  
  select sum(p.payment)
  into: przychod
  from
   danepro.payments as p
   join 
   __temp__ as t
   on p.paymentId = t.paymentId;
   
  select count(t.paymentId)
  into: lKlientow
  from __temp__ as t
  where t.status=1;
   
 run;
 
 data __temp__;
 lKlientow = &lKlientow.;
 przychod = &przychod.;
 run;
  
 proc print data = __temp__ label;
 title1 height=25pt "Informacje biznesowe o locie nr &idLotu.";
 label lKlientow='Liczba Pasażerów' przychod='Przychód z lotu (w $)';
 var lKlientow przychod; 
 run;
 proc delete data=__temp__;run;
 proc delete data=__temp2__;run;
 
 proc sgmap plotdata=danepro.airports(where=(airportId = &depAirportId. or airportId= &destAirportId.)) mapdata=mapsgfk.world;
   openstreetmap;
   scatter x=longitude y=latitude / markerattrs=(symbol=circlefilled color=red size=15)
   datalabel=city legendlabel='Miasto';
   title 'Lot na mapie';
   footNote1 "Analiza została wykonana przez &imiePracownika. &nazwiskoPracownika. - &pozycja."; 

run;
 


%mend podsumujLot;

%podsumujLot(idLotu=12)

/* 2. Analiza wplywu na srodowisko */


%macro wplywNaSrodowisko();

  data _null_;
  set danepro.employees;
   where employeeId = 1;
  
  sformatowanaPozycja = put(occupationId, occupations.);
   
  call symputx('imiePracownika', firstname);
  call symputx('nazwiskoPracownika', lastname);
  call symputx('pozycja', sformatowanaPozycja);
  
 run;


proc univariate data = danepro.flights noprint;
 var tracklength;
 title 'Rozkład długości lotów';
 HISTOGRAM;
run;

proc sql;
 create table flights_planes as
 select f.flightId,f.trackLength,p.planeId ,a.category, f.departureAirportId, f.destinationAirportId
 from 
  danepro.flights as f
   join
  danepro.planes as p
   on p.planeId = f.planeId
   join 
  danepro.aircraftsmodels as a
 on p.modelId = a.modelId
 ; 
quit;

options cmplib = (funk.funkcje _DISPLAYLOC_);
data __temp__;
 set flights_planes;
 emission = round(obliczWydaloneCO2(trackLength, category),0.01);
run;

options cmplib = _null_;

proc univariate data = __temp__ noprint;
 var emission;
 title 'Rozkład wydalanego CO2 podczas lotów';

 HISTOGRAM;
run;

proc sort data=__temp__;
by planeId;
run;

proc sgplot data=__temp__;
    vbar planeId / response=emission datalabel
        categoryorder=respdesc;
    title "Suma wyemitowanych kg CO2 pogrupowane po samolotach";
run;

data _temp_;
 set __temp__;
 /* dodajemy id trasy */
 length idTrasy $ 5;
 idTrasy = catx('_', departureAirportId, destinationAirportId);
 output;
run;


proc sql;
 create table __temp2__ as
  select sum(emission) as emission, idTrasy
  from _temp_
  group by idTrasy;
quit;

proc sort data=__temp2__;
by emission;
run;

/* wybranie 20 najlepszych */

data __temp3__;
 set __temp2__;
 if _n_<= 20 then output;
 else stop;
run;

/* wybranie 20 najgorszych */
data __temp4__;
 set __temp2__ nobs=nobs;
 if _n_>= nobs-20 then output;
run;




proc sgplot data=__temp3__;
    vbar idTrasy / response=emission datalabel
    categoryorder=respdesc;
    title "Suma wyemitowanych kg CO2 dla 20 najlepszych tras";
run;

proc sgplot data=__temp4__;
    vbar idTrasy / response=emission datalabel
    categoryorder=respdesc;
    title "Suma wyemitowanych kg CO2 dla 20 najgorszych tras";
    footNote1 "Analiza została wykonana przez &imiePracownika. &nazwiskoPracownika. - &pozycja."; 

run;


%mend wplywNaSrodowisko;

%wplywNaSrodowisko()

/* 3. Mapa lotnisk */

%macro zrobMape();


proc sgmap plotdata=danepro.airports mapdata=mapsgfk.world;
   openstreetmap;
   scatter x=longitude y=latitude / markerattrs=(symbol=circlefilled color=red size=5)
   datalabel=airportcode legendlabel='Kod lotniska';
   title 'Lotniska proponowane w naszej ofercie';
   
run;

%mend zrobMape;

%zrobMape()