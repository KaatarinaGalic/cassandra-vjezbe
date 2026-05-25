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
