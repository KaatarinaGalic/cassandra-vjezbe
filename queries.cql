-- Korak 1
-- Provjera vremena i rada Cassandra instance
SELECT now() FROM system.local;


-- Kreiranje keyspace-a zadatak 2
CREATE KEYSPACE IF NOT EXISTS vjezba
WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': 1
};

USE vjezba;

CREATE TABLE narudzbe (
  korisnik_id UUID,
  created_at TIMESTAMP,
  narudzba_id UUID,
  ukupno DECIMAL,
  status TEXT,
  grad TEXT,
  PRIMARY KEY (korisnik_id, created_at)
) WITH CLUSTERING ORDER BY (created_at DESC);

CREATE TABLE proizvodi (
  id UUID PRIMARY KEY,
  naziv TEXT,
  cijena DECIMAL,
  kategorija TEXT,
  dostupnost BOOLEAN
);

CREATE TABLE recenzije (
  proizvod_id UUID,
  korisnik_id UUID,
  ocjena INT,
  komentar TEXT,
  created_at TIMESTAMP,
  PRIMARY KEY (proizvod_id, korisnik_id)
);

-- peta dodana tabela pregledi_proizvoda
CREATE TABLE pregledi_proizvoda (
  korisnik_id UUID,
  datum TIMESTAMP,
  proizvod_id UUID,
  naziv_proizvoda TEXT,
  PRIMARY KEY (korisnik_id, datum)
);
--Zadatak3 
--unos proizvoda

INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Laptop Pro 15', 1299.99, 'elektronika', true);

INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Bežične slušalice', 149.99, 'elektronika', true);

INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Ergonomska stolica', 349.00, 'namještaj', true);

INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Mehanička tipkovnica', 89.99, 'elektronika', false);

INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Monitor 27"', 499.00, 'elektronika', true);

INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (uuid(), 'Radni stol', 279.00, 'namještaj', true);

SELECT * FROM proizvodi;

--korisnik A
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (11111111-1111-1111-1111-111111111111,
        toTimestamp(now()), uuid(), 1449.98, 'isporuceno', 'Zagreb');

INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (11111111-1111-1111-1111-111111111111,
        toTimestamp(now()), uuid(), 349.00, 'u_obradi', 'Zagreb');

INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (11111111-1111-1111-1111-111111111111,
        toTimestamp(now()), uuid(), 89.99, 'isporuceno', 'Zagreb');

--korisnik B 
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (22222222-2222-2222-2222-222222222222,
        toTimestamp(now()), uuid(), 499.00, 'isporuceno', 'Split');

INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (22222222-2222-2222-2222-222222222222,
        toTimestamp(now()), uuid(), 279.00, 'otkazano', 'Split');

-- treci korisnik

INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (33333333-3333-3333-3333-333333333333,
        toTimestamp(now()), uuid(), 120.00, 'isporuceno', 'Mostar');

INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (33333333-3333-3333-3333-333333333333,
        toTimestamp(now()), uuid(), 75.50, 'u_obradi', 'Sarajevo');

INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (33333333-3333-3333-3333-333333333333,
        toTimestamp(now()), uuid(), 220.00, 'isporuceno', 'Mostar');

--UPSERT semantika
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (
33333333-3333-3333-3333-333333333333,
toTimestamp(now()),
uuid(),
9999.99,
'isporuceno',
'Mostar'
); 

--Provjera
SELECT * FROM narudzbe;


--Zadatak 4 
-- a. pronaći sve narudžbe trećeg korisnika 
SELECT * FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;
-- b. pronaći sve narudžbe sa statusom 'isporuceno' koristeći ALLOW FILTERING 
SELECT * FROM narudzbe
WHERE status = 'isporuceno'
ALLOW FILTERING;

-- c testirati TTL: umetnuti narudžbu s TTL=30 sekundi, odmah provjeriti TTL(status), pričekati 35 sekundi i potvrditi da zapis ne postoji
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad)
VALUES (33333333-3333-3333-3333-333333333333,
        toTimestamp(now()), uuid(),
        55.55, 'test', 'Mostar')
USING TTL 30;

--Provjera
SELECT TTL(status), status, grad
FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;

--nakon 35s
SELECT * FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;

--Zadatak 5
--a UPDATE status narudžbe
UPDATE narudzbe
SET status = 'isporuceno'
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333
  AND created_at = '2026-05-25 17:55:39.478000+0000';

--Provjera
SELECT * FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;

--b LWT
INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost)
VALUES (be3bde2c-b965-4609-8307-134e79f71343, 'Novi proizvod', 49.99, 'ostalo', true)
IF NOT EXISTS;

--DELETE narudžbe
DELETE FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333
  AND created_at = '2026-05-25 17:55:38.150000+0000';

--Provjera
SELECT * FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;
