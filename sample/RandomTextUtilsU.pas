unit RandomTextUtilsU;

interface

const
  FirstNames: array [0 .. 9] of string = (
    'Daniele',
    'Debora',
    'Mattia',
    'Jack',
    'James',
    'William',
    'Joseph',
    'David',
    'Charles',
    'Thomas'
    );

  LastNames: array [0 .. 9] of string = (
    'Smith',
    'JOHNSON',
    'Williams',
    'Brown',
    'Jones',
    'Miller',
    'Davis',
    'Wilson',
    'Martinez',
    'Anderson'
    );

  Countries: array [0 .. 9] of string = (
    'Italy',
    'New York',
    'Illinois',
    'Arizona',
    'Nevada',
    'UK',
    'France',
    'Germany',
    'Norway',
    'California'
    );
  HouseTypes: array [0 .. 9] of string = (
    'Dogtrot house',
    'Deck House',
    'American Foursquare',
    'Mansion',
    'Patio house',
    'Villa',
    'Georgian House',
    'Georgian Colonial',
    'Cape Dutch',
    'Castle'
    );

function GetRndFirstName: String;
function GetRndLastName: String;
function GetRndCountry: String;
function GetRndHouse: String;

implementation

function GetRndHouse: String;
begin
  Result := 'Mr.' + GetRndLastName + '''s ' + HouseTypes[Random(10)] + ' (' + GetRndCountry + ')';
end;

function GetRndCountry: String;
begin
  Result := Countries[Random(10)];
end;

function GetRndFirstName: String;
begin
  Result := FirstNames[Random(10)];
end;

function GetRndLastName: String;
begin
  Result := LastNames[Random(10)];
end;

end.

