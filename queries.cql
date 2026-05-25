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
-- kreiranje tabele narudzbe

CREATE TABLE narudzbe (
  korisnik_id UUID,
  created_at TIMESTAMP,
  narudzba_id UUID,
  ukupno DECIMAL,
  status TEXT,
  grad TEXT,
  PRIMARY KEY (korisnik_id, created_at)
) WITH CLUSTERING ORDER BY (created_at DESC);

-- lreiranje tabele proizvodi
CREATE TABLE proizvodi (
  id UUID PRIMARY KEY,
  naziv TEXT,
  cijena DECIMAL,
  kategorija TEXT,
  dostupnost BOOLEAN
);

-- kreiranje tabele recenzije

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

-- pregled svih proizvoda
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

-- korisnik B 
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

--6 Zadatak

CREATE INDEX idx_dostupnost ON proizvodi (dostupnost);
--Provjera
SELECT naziv, cijena, dostupnost
FROM proizvodi
WHERE dostupnost = true;

--Materialized View (po statusu narudžbe)

CREATE MATERIALIZED VIEW narudzbe_po_statusu AS
SELECT *
FROM narudzbe
WHERE status IS NOT NULL
  AND korisnik_id IS NOT NULL
  AND created_at IS NOT NULL
PRIMARY KEY (status, korisnik_id, created_at)
WITH CLUSTERING ORDER BY (korisnik_id ASC, created_at DESC);


--SUM
SELECT SUM(ukupno) AS ukupna_potrosnja
FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;

--AVG
SELECT AVG(ukupno) AS prosjecna_narudzba
FROM narudzbe
WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;

--7 Korak
DESCRIBE KEYSPACE vjezba;
DESCRIBE TABLE narudzbe;
SELECT * FROM system_schema.indexes
WHERE keyspace_name = 'vjezba';

--Zavrsni zadatak

-- tabela tecaj
CREATE TABLE tecaj (
  tecaj_id UUID PRIMARY KEY,
  naziv TEXT,
  instruktor TEXT,
  kategorija TEXT,
  cijena DECIMAL,
  trajanje_sati INT
);

--tablica upis
CREATE TABLE upis (
  student_id UUID,
  tecaj_id UUID,
  datum_upisa TIMESTAMP,
  napredak INT,
  status TEXT,
  PRIMARY KEY (student_id, tecaj_id)
);
--tablica lekcija
CREATE TABLE lekcija (
  tecaj_id UUID,
  redni_broj INT,
  naslov TEXT,
  trajanje_min INT,
  sadrzaj_url TEXT,
  PRIMARY KEY (tecaj_id, redni_broj)
) WITH CLUSTERING ORDER BY (redni_broj ASC);


--insert tecaj
INSERT INTO tecaj (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati)
VALUES (uuid(), 'Python Basics', 'Ana', 'programiranje', 99.99, 20);

INSERT INTO tecaj (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati)
VALUES (uuid(), 'Data Science', 'Ivan', 'AI', 199.99, 40);

INSERT INTO tecaj (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati)
VALUES (uuid(), 'Web Dev', 'Marko', 'frontend', 149.99, 35);

INSERT INTO tecaj (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati)
VALUES (uuid(), 'SQL Basics', 'Ivana', 'baze', 79.99, 15);

INSERT INTO tecaj (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati)
VALUES (uuid(), 'Machine Learning', 'Sara', 'AI', 299.99, 50);

--insert upis 10
INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (11111111-1111-1111-1111-111111111111, uuid(), toTimestamp(now()), 30, 'active');

INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (11111111-1111-1111-1111-111111111111, uuid(), toTimestamp(now()), 70, 'active');

INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (22222222-2222-2222-2222-222222222222, uuid(), toTimestamp(now()), 50, 'active');

INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (22222222-2222-2222-2222-222222222222, uuid(), toTimestamp(now()), 90, 'completed');

INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (33333333-3333-3333-3333-333333333333, uuid(), toTimestamp(now()), 10, 'active');

INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (33333333-3333-3333-3333-333333333333, uuid(), toTimestamp(now()), 40, 'active');

INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (11111111-1111-1111-1111-111111111111, uuid(), toTimestamp(now()), 55, 'active');

INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (22222222-2222-2222-2222-222222222222, uuid(), toTimestamp(now()), 20, 'active');

INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (33333333-3333-3333-3333-333333333333, uuid(), toTimestamp(now()), 75, 'active');

INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (11111111-1111-1111-1111-111111111111, uuid(), toTimestamp(now()), 95, 'completed');

--inssert lekcije 
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (0684ab14-c292-4d23-97a6-c9c804b9cfd1, 1, 'Uvod u Python', 10, 'url1');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (0684ab14-c292-4d23-97a6-c9c804b9cfd1, 2, 'Varijable', 15, 'url2');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (0684ab14-c292-4d23-97a6-c9c804b9cfd1, 3, 'Petlje', 20, 'url3');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (3e570022-5a93-4795-8451-4e0f42ffb156, 1, 'Uvod u Data Science', 20, 'url4');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (3e570022-5a93-4795-8451-4e0f42ffb156, 2, 'Pandas osnove', 25, 'url5');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (3e570022-5a93-4795-8451-4e0f42ffb156, 3, 'Vizualizacija', 30, 'url6');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (35bfe48b-9f28-4e29-8da0-49aaff5a210a, 1, 'HTML/CSS', 20, 'url7');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (35bfe48b-9f28-4e29-8da0-49aaff5a210a, 2, 'JavaScript', 25, 'url8');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (35bfe48b-9f28-4e29-8da0-49aaff5a210a, 3, 'Vue basics', 30, 'url9');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (fe0512a7-95d9-4235-a92a-09fd273010c3, 1, 'SELECT', 10, 'url10');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (fe0512a7-95d9-4235-a92a-09fd273010c3, 2, 'JOIN', 20, 'url11');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (fe0512a7-95d9-4235-a92a-09fd273010c3, 3, 'Indexi', 15, 'url12');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (775123c8-7952-4f85-915d-5fa7ab74a0c6, 1, 'Uvod u ML', 20, 'url13');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (775123c8-7952-4f85-915d-5fa7ab74a0c6, 2, 'Linearna regresija', 30, 'url14');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url)
VALUES (775123c8-7952-4f85-915d-5fa7ab74a0c6, 3, 'Model evaluacija', 25, 'url15');

--pregled
-- PROVJERA TECAJEVA
SELECT * FROM tecaj;

-- PROVJERA UPISA
SELECT * FROM upis;

--PROVJERA LEKCIJA
SELECT * FROM lekcija;

--lekcije po tecaju
SELECT * FROM lekcija
WHERE tecaj_id = 0684ab14-c292-4d23-97a6-c9c804b9cfd1;

SELECT * FROM lekcija
WHERE tecaj_id = 775123c8-7952-4f85-915d-5fa7ab74a0c6;

--svi upisi studenata
SELECT * FROM upis
WHERE student_id = 11111111-1111-1111-1111-111111111111;

SELECT * FROM upis
WHERE student_id = 22222222-2222-2222-2222-222222222222;

SELECT * FROM upis
WHERE student_id = 33333333-3333-3333-3333-333333333333;

--UPDATE upit azuriranje napretka studenata za odredjeni tecajUPDATE upis
SET napredak = 85
WHERE student_id = 11111111-1111-1111-1111-111111111111
  AND tecaj_id = 775123c8-7952-4f85-915d-5fa7ab74a0c6;

--TTL
INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status)
VALUES (
  11111111-1111-1111-1111-111111111111,
  775123c8-7952-4f85-915d-5fa7ab74a0c6,
  toTimestamp(now()),
  0,
  'trial'
)
USING TTL 604800;

--Provjera
SELECT student_id, tecaj_id, status, TTL(status)
FROM upis
WHERE student_id = 11111111-1111-1111-1111-111111111111;

-- COUNT upisa po tečaju

SELECT COUNT(*) FROM upis
WHERE tecaj_id = 775123c8-7952-4f85-915d-5fa7ab74a0c6
ALLOW FILTERING;

--AVG napretka po studentu

SELECT AVG(napredak) FROM upis
WHERE student_id = 11111111-1111-1111-1111-111111111111;
