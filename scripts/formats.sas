/* stworzenie formatu z zbioru countries */
data danepro.countriesFormat;
  length FMTNAME $ 9 TYPE $ 1 LABEL $ 40;


  retain FMTNAME 'countries' TYPE "N";

  do until(EOF);
    set danepro.countries end=EOF;
      LABEL = country;  
      START = countryId; 
      output;
  end;

  call missing (START);
  HLO = 'O'; 

  LABEL = '#ERROR#'; /* Błędne id*/
  output;

stop;
drop country countryId;
run;

proc format LIBRARY = work CNTLIN = danepro.countriesFormat;
run;

/* stworzenie formatu z zbioru occupations */

data danepro.occupationsFormat;
  length FMTNAME $ 11 TYPE $ 1 LABEL $ 26;


  retain FMTNAME 'occupations' TYPE "N";

  do until(EOF);
    set danepro.occupations end=EOF;
      LABEL = occupation;  
      START = occupationId; 
      output;
  end;

  call missing (START);
  HLO = 'O'; 

  LABEL = '#ERROR#'; /* Błędne id*/
  output;

stop;
drop occupation occupationId;
run;

proc format LIBRARY = work CNTLIN = danepro.occupationsFormat;
run;

/* stworzenie formatu z zbioru aircraftsProducers */

data danepro.producersFormat;
  length FMTNAME $ 9 TYPE $ 1 LABEL $ 25;


  retain FMTNAME 'producers' TYPE "N";

  do until(EOF);
    set danepro.aircraftsProducers end=EOF;
      LABEL = producer;  
      START = producerId; 
      output;
  end;

  call missing (START);
  HLO = 'O'; 

  LABEL = '#ERROR#'; /* Błędne id*/
  output;

stop;
drop producer producerId;
run;

proc format LIBRARY = work CNTLIN = danepro.producersFormat;
run;


/* stworzenie formatu z zbioru aircraftsModels*/

data danepro.modelsFormat;
  length FMTNAME $ 6 TYPE $ 1 LABEL $ 15;


  retain FMTNAME 'models' TYPE "N";

  do until(EOF);
    set danepro.aircraftsModels end=EOF;
      LABEL = aircraftModel;  
      START = modelId; 
      output;
  end;

  call missing (START);
  HLO = 'O'; 

  LABEL = '#ERROR#'; /* Błędne id*/
  output;

stop;
drop aircraftModel modelId;
run;

proc format LIBRARY = work CNTLIN = danepro.modelsFormat;
run;



/* stworzenie formatu z zbioru airports */

/* format dla miast*/
data danepro.airportsCityFormat;
  length FMTNAME $ 11 TYPE $ 1 LABEL $ 50;


  retain FMTNAME 'airportCity' TYPE "N";

  do until(EOF);
    set danepro.airports end=EOF;
      LABEL = city;  
      START = airportId; 
      output;
  end;

  call missing (START);
  HLO = 'O'; 

  LABEL = '#ERROR#'; /* Błędne id kraju*/
  output;

stop;
drop city airportId;
run;

proc format LIBRARY = work CNTLIN = danepro.airportsCityFormat;
run;

/* format dla nazw lotnisk*/

data danepro.airportsNameFormat;
  length FMTNAME $ 11 TYPE $ 1 LABEL $ 80;


  retain FMTNAME 'airportName' TYPE "N";

  do until(EOF);
    set danepro.airports end=EOF;
      LABEL = name;  
      START = airportId; 
      output;
  end;

  call missing (START);
  HLO = 'O'; 

  LABEL = '#ERROR#'; /* Błędne id kraju*/
  output;

stop;
drop name airportId;
run;

proc format LIBRARY = work CNTLIN = danepro.airportsNameFormat;
run;













