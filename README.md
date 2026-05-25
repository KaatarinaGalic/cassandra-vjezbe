# Cassandra vježba

## Opis projekta

Ovaj projekt prikazuje rad s Apache Cassandra distribuiranom wide-column bazom podataka i CQL query jezikom kroz praktične zadatke. Cilj je bio kreirati keyspace i tablice, unositi i dohvaćati podatke te raditi s različitim Cassandra funkcionalnostima poput TTL-a, indeksa i Materialized View-a.

---

## Pokretanje projekta

Pokretanje Cassandra okruženja:

```bash
docker compose up -d
```

Provjera pokrenutih kontejnera:

```bash
docker compose ps
```

Kontejner mora imati status `running` ili `healthy`.

---

## Spajanje na cqlsh

```bash
docker exec -it cassandra-cassandra-1 cqlsh
```

---

## Servisi

CQL port:  
localhost:9042

---

## Sadržaj repozitorija

- `docker-compose.yml` → konfiguracija Cassandra okruženja
- `queries.cql` → svi CQL upiti korišteni tijekom vježbe
- `screenshots/` → screenshotovi izvršavanja zadataka
- `ODGOVORI.md` → teorijski odgovori
- `README.md` → opis projekta

---

## Funkcionalnosti

- kreiranje keyspace-a i tablica
- INSERT, SELECT, UPDATE i DELETE upiti
- partition key i clustering columns
- TTL (Time To Live)
- Lightweight Transactions (LWT)
- Secondary Index
- Materialized View
- agregacije i filtriranje podataka

---

## Napomena

Projekt je rađen postepeno kroz više commitova u Visual Studio Code okruženju.