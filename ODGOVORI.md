# Zadatak 1.
Cassandra koristi port 9042 za CQL komunikaciju. Taj port koriste cqlsh i aplikacije koje se spajaju na bazu podataka.
Cassandra nema ugrađeno web sučelje jer je fokusirana na distribuiranu obradu podataka i rad kroz CQL klijente i drivere. Administracija se uglavnom radi kroz terminal i alate za monitoring.

# Zadatak 2
## Zašto je partition key vazan u Cassandri
Partition key određuje na kojem će se čvoru podaci spremiti. Cassandra koristi hash partition key-a za raspodjelu podataka kroz klaster i zato je njegov odabir ključan za performanse i ravnomjerno opterećenje sustava.
## Hot partition problem
Ako veliki broj zapisa koristi isti partition key, svi podaci završavaju na istom čvoru. To uzrokuje preopterećenje jednog dijela klastera, sporije upite i problem poznat kao hot partition.

# Zadatak 3
Cassandra INSERT ima upsert semantiku. Kada se unese red s istim primary key-em (korisnik_id + created_at), novi zapis prepisuje stari. U testu je vrijednost ukupno promijenjena u novu vrijednost, što potvrđuje da Cassandra ne radi update nego overwrite na razini ključa.

# Zadatak 4
## Zašto je ALLOW FILTERING problematican:
ALLOW FILTERING u Cassandri je problematičan jer omogućuje skeniranje svih particija u bazi umjesto ciljanja jedne. To znači da Cassandra mora pregledati veliki broj čvorova, što značajno smanjuje performanse. U produkciji to može uzrokovati veliko opterećenje klastera i spore upite.


## Kratko objasniti razliku između partition key i clustering column u kontekstu CQL WHERE upita 
Partition key određuje na kojem čvoru se podaci fizički spremaju i koristi se za brzo lociranje podataka. Clustering column određuje redoslijed podataka unutar iste particije. U ovom zadatku korisnik_id je partition key, a created_at clustering column pa se narudžbe jednog korisnika čuvaju zajedno i sortiraju po vremenu.

# Zadatak 5
## Tombstone u Cassandri
Tombstone je marker koji Cassandra ostavlja kada se izvrši DELETE umjesto da odmah fizički briše podatak. Razlog je što Cassandra radi distribuirano i ne može odmah sinkronizirano ukloniti podatke sa svih čvorova. Podaci se trajno brišu tek tijekom compaction procesa kada se spajaju SSTable datoteke i uklanjaju zastarjeli zapisi.

# Zadatak 6
## Materialized View

Materialized View omogućuje kreiranje alternativnog primarnog ključa nad postojećom tablicom i automatsko održavanje podataka. U ovom slučaju MV je trebao omogućiti query po statusu narudžbe bez ALLOW FILTERING. U mom okruženju Materialized Views su onemogućeni u Cassandra konfiguraciji (docker setup), pa se ne mogu izvršiti, ali konceptualno služe za optimizaciju čitanja uz povećan write overhead.

## Secondary Index vs Materialized View

Secondary Index se koristi kada želimo filtrirati po stupcu koji nije partition key bez mijenjanja modela tablice, ali može biti spor jer kontaktira više čvorova. Materialized View kreira novu fizičku tablicu s drugačijim primary key-em i omogućuje brze upite, ali povećava write overhead jer se podaci moraju održavati u dvije strukture.