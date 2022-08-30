create database popdb;
use popdb;
create external table popbycounty (
    decennialTime int,
    stateName string,
    countyName string,
    population bigint,
    race string,
    sex string,
    minAge int,
    maxAge int,
    year int
)
stored as orc
location '/example/popbycorc';
