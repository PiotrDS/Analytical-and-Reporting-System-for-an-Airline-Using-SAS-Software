/*podlaczenie biblioteki */
libname danepro
base
'/home/u63796376/daneProjekt';

/* Ustawienie kluczy glownych */

%setPrimaryKey(ds=danepro.Customers, pk=customerId)
%setPrimaryKey(ds=danepro.occupations, pk=occupationId)
%setPrimaryKey(ds=danepro.aircraftsProducers, pk=producerId)
%setPrimaryKey(ds=danepro.aircraftsmodels, pk=modelId)
%setPrimaryKey(ds=danepro.employees, pk=employeeId)
%setPrimaryKey(ds=danepro.flights, pk=flightId)
%setPrimaryKey(ds=danepro.planes, pk=planeId)
%setPrimaryKey(ds=danepro.repairHistory, pk=repairId)
%setPrimaryKey(ds=danepro.airports, pk=airportId)
%setPrimaryKey(ds=danepro.countries, pk=countryId)
%setPrimaryKey(ds=danepro.repairTypes, pk=typeId)

/* Ustawienie kluczy obcych oraz ograniczen danych */

proc datasets lib =danepro nolist;

/* zbiór danych flights */
 modify flights;
   ic create FK_FLIGHTS_PLANES =foreign key (planeId) references planes;
   ic create FK_FLIGHTS_DEPAIRPORT =foreign key (departureAirportId) references airports;
   ic create FK_FLIGHTS_DESTAIRPORT =foreign key (destinationAirportId) references airports;
   ic create DATAVALIDATION = check(where = (arrivalDate > departureDate));


/* zbiór danych aircraftsProducers */
 modify aircraftsProducers;
   ic create FK_CUSTOMERS_COUNTRIES =foreign key (countryId) references Countries;


/* zbiór danych customers */
 modify customers;
   ic create FK_PRODUCERS_COUNTRIES =foreign key (countryId) references Countries;
   ic create NN_FIRSTNAME=not null (firstName);
   ic create NN_LASTNAME=not null (lastName);
   ic create NN_EMAIL=not null (email);
   ic create UNIQUE_EMAIL = unique(email);
   ic create NN_PHONENUMBER =not null (phoneNumber);
   ic create UNIQUE_PHONENUMBER = unique(phoneNumber);
   ic create NN_LOYALTYLEVEL=not null (loyaltyLevel);   


/* zbiór danych aircraftsmodels */

 modify aircraftsmodels;
   ic create FK_MODELS_PRODUCERS =foreign key (producerId) references aircraftsProducers;
   ic create NN_AIRCRAFTMODEL=not null (aircraftModel);
   ic create NN_CATEGORY =not null (category);
   ic create NN_NUMBEROFSEATS=not null (numberOfSeats);
   
/* zbiór danych employees */
 modify employees;
   ic create FK_EMPLOYEES_OCCUPATIONS = foreign key(occupationId) references occupations;
   ic create NN_FIRSTNAME=not null (firstName);
   ic create NN_LASTNAME=not null (lastName);
   
/* zbiór danych flightService */
 modify flightService;
   ic create FK_FLIGHTSERVICE_EMPLOYEES = foreign key(employeeId) references employees;
   ic create FK_FLIGHTSERVICE_FLIGHTS = foreign key(flightId) references flights;

/* zbiór danych flightReservations */
 modify flightReservations; 
   ic create FK_FLIGHTRESERVATIONS_CUSTOMERS = foreign key(customerId) references customers;
   ic create FK_FLIGHTRESERVATIONS_FLIGHTS = foreign key(flightId) references flights;
   ic create NN_CLASS=not null (class);
   ic create NN_SEATNUMBER=not null (seatNumber);

/* zbiór danych flightLog */
 modify flightLog;
   ic create FK_FLIGHTLOG_FLIGHTS = foreign key(flightId) references flights;
   ic create NN_LOG=not null (log);
   ic create NN_LOGDATE=not null (logDate);
 
/* zbiór danych planes */
 modify planes;
   ic create FK_PLANES_MODELS = foreign key(modelId) references aircraftsModels;
   ic create NN_PRODUCTIONYEAR=not null (productionYear);
   ic create NN_STATUS=not null (status); 
   ic create DATAVALIDATION = check(where = (productionYear <= 2025));
   
/* zbiór danych repairHistory */
 modify repairHistory;
   ic create FK_REPAIRS_PLANES = foreign key(planeId) references planes;
   ic create FK_REPAIRS_TYPES = foreign key(typeId) references repairTypes;
   ic create DATAVALIDATION = check(where = (endRepairDate > startRepairDate));

/* zbiór danych Airports*/
 modify Airports;
   ic create FK_AIRPORTS_COUNTRIES = foreign key(countryId) references countries;
   ic create NN_NAME=not null (name);
   ic create NN_CITY=not null (city);    
   ic create NN_AIRPORTCODE=not null (airportCode);
   ic create NN_LATITUDE=not null (latitude); 
   ic create NN_LONGITUDE=not null (longitude); 
   
quit;


/* -----------------dodanie indeksow---------------------- */

proc datasets lib =danepro nolist;
 modify flights;
  index create planes_depAirport_destAirport = (planeId departureAirportId destinationAirportId);
 
 
 modify repairHistory;
  index create planes_repairsTypes = (planeId typeId);
 
 modify customers;
  index create customers_countries = (customerId countryId);
  

quit;

/*----------------USUWANIE WIEZOW - OSTROZNIE !!!!!---------*/


proc datasets lib =danepro nolist;

/* zbiór danych flightService */
 modify flightService;
  ic delete _all_;
  index delete _all_;

/* zbiór danych flightReservations */
 modify flightReservations; 
  ic delete _all_;
  index delete _all_;


/* zbiór danych flightLog */
 modify flightLog;
  ic delete _all_;
  index delete _all_;


/* zbiór danych flights */
 modify flights;
  ic delete _all_;
  index delete _all_;

  
 /* zbiór danych employees */
 modify employees;
  ic delete _all_;
  index delete _all_;


/* zbiór danych occupations*/
 modify occupations;
  ic delete _all_;
  index delete _all_;
  
  
/* zbiór danych repairHistory */
 modify repairHistory;
  ic delete _all_;
  index delete _all_;
  

/* zbiór danych planes */
 modify planes;
  ic delete _all_;
  index delete _all_;


/* zbiór danych aircraftsmodels */

 modify aircraftsmodels;
  ic delete _all_;
  index delete _all_;

/* zbiór danych aircraftsProducers */
 modify aircraftsProducers;
  ic delete _all_;
  index delete _all_;

/* zbiór danych customers */
 modify customers;
  ic delete _all_;
  index delete _all_;
  
/* zbiór danych repairTypes*/
 modify repairTypes;
  ic delete _all_;
  index delete _all_;

 

/* zbiór danych Airports*/
 modify Airports;
  ic delete _all_;
  index delete _all_;
  
/* zbiór danych countries*/
 modify countries;
  ic delete _all_;
  index delete _all_;

quit;

/*----------------USUWANIE ZBIOROW - OSTROZNIE !!!!!---------*/

proc datasets library=danepro nolist kill; run; quit;
