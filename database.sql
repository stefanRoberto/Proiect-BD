CREATE TABLE pr_vanzatori (
    id_vanzator NUMBER(2) PRIMARY KEY,
    nume VARCHAR2(50) NOT NULL,
    telefon VARCHAR2(20) NOT NULL,
    email VARCHAR2(40),
    adresa VARCHAR2(50) NOT NULL
);

CREATE TABLE pr_clienti (
    id_client NUMBER(2) PRIMARY KEY,
    nume VARCHAR2(50) NOT NULL,
    telefon VARCHAR2(20) NOT NULL,
    email VARCHAR2(40),
    adresa VARCHAR2(50) NOT NULL
);

CREATE TABLE pr_masini (
    id_masina NUMBER(2) PRIMARY KEY,
    marca VARCHAR2(30) NOT NULL,
    model VARCHAR2(30) NOT NULL,
    an_fabricatie NUMBER(4) NOT NULL,
    id_vanzator NUMBER(2) NOT NULL,
    FOREIGN KEY (id_vanzator) REFERENCES pr_vanzatori(id_vanzator)
);

CREATE TABLE pr_comenzi (
    id_comanda NUMBER(2) PRIMARY KEY,
    id_masina NUMBER(2) NOT NULL,
    id_client NUMBER(2) NOT NULL,
    data_comanda DATE NOT NULL,
    FOREIGN KEY (id_masina) REFERENCES pr_masini(id_masina),
    FOREIGN KEY (id_client) REFERENCES pr_clienti(id_client)
);

CREATE TABLE pr_plati (
    id_plata NUMBER(2) PRIMARY KEY,
    id_comanda NUMBER(2) NOT NULL,
    valoare DECIMAL(10, 2) NOT NULL,
    CONSTRAINT valoare_pozitiva CHECK (valoare > 0),
    data_plata DATE NOT NULL,
    FOREIGN KEY (id_comanda) REFERENCES pr_comenzi(id_comanda)
);

INSERT INTO pr_vanzatori (id_vanzator, nume, telefon, email, adresa) VALUES (1, 'Ion Popescu', '0743211234', 'ion.popescu@gmail.com', 'Str. Ion Creanga nr. 10');

INSERT INTO pr_clienti (id_client, nume, telefon, email, adresa) VALUES (1, 'Marian Moga', '0745442456', 'marian.moga@gmail.com', 'Str. George Cosbuc nr. 12');

INSERT INTO pr_masini (id_masina, marca, model, an_fabricatie, id_vanzator) VALUES (1, 'Toyota', 'Corolla', 2010, 1);

INSERT INTO pr_comenzi (id_comanda, id_masina, id_client, data_comanda) VALUES (1, 1, 1, to_date('01-06-2020','dd-mm-yyyy'));

INSERT INTO pr_plati (id_plata, id_comanda, valoare, data_plata) VALUES (1, 1, 10000, to_date('03-06-2020','dd-mm-yyyy'));

UPDATE pr_vanzatori SET nume = 'Ionut Popa' WHERE id_vanzator = 1;

UPDATE pr_clienti SET adresa = 'Str. Mihai Eminescu nr. 15' WHERE id_client = 1;

DELETE FROM pr_plati WHERE id_plata = 1;

DELETE FROM pr_comenzi WHERE data_comanda LIKE '01%';

SELECT * FROM pr_vanzatori;

SELECT nume, adresa FROM pr_clienti WHERE id_client = 1;

SELECT marca, model, an_fabricatie FROM pr_masini INNER JOIN pr_vanzatori ON pr_masini.id_vanzator = pr_vanzatori.id_vanzator WHERE pr_vanzatori.nume = 'Ionut Popa';

MERGE INTO pr_vanzatori vz
USING (SELECT id_client, nume, telefon, email, adresa FROM pr_clienti) cl
ON (vz.id_vanzator = cl.id_client)
WHEN MATCHED THEN
    UPDATE SET vz.nume = cl.nume, vz.telefon = cl.telefon, vz.email = cl.email, vz.adresa= cl.adresa
WHEN NOT MATCHED THEN 
    INSERT (nume, telefon, email, adresa)
    VALUES (cl.nume, cl.telefon, cl.email, cl.adresa);

SELECT * FROM pr_vanzatori WHERE id_vanzator = ANY (SELECT id_vanzator FROM pr_masini);

SELECT * FROM pr_vanzatori WHERE nume = ALL (SELECT nume FROM pr_clienti);

SELECT * FROM pr_comenzi INNER JOIN pr_masini ON pr_comenzi.id_masina = pr_masini.id_masina;

SELECT * FROM pr_comenzi LEFT OUTER JOIN pr_plati ON pr_comenzi.id_comanda = pr_plati.id_comanda;

SELECT * FROM pr_clienti WHERE EXISTS (SELECT * FROM pr_comenzi WHERE pr_clienti.id_client = pr_comenzi.id_client);

SELECT * FROM pr_vanzatori WHERE NOT EXISTS (SELECT * FROM pr_masini WHERE pr_vanzatori.id_vanzator = pr_masini.id_vanzator);

SELECT UPPER(nume) as "Nume" FROM pr_clienti;

SELECT nume || ' ' || adresa as "Nume si Adresa" FROM pr_clienti;

SELECT SUBSTR(marca, 1, 3) as "Initialele marcii" FROM pr_masini;

SELECT SYSDATE as "Data curenta" FROM DUAL;

SELECT MONTHS_BETWEEN(SYSDATE, data_comanda) as "Diferenta luni data comenzii" FROM pr_comenzi;

SELECT ADD_MONTHS(data_comanda, 6) as "Data comenzii + 6 luni" FROM pr_comenzi;

SELECT NEXT_DAY(data_comanda, 'MONDAY') as "Urmatoarea zi de luni" FROM pr_comenzi;

SELECT LAST_DAY(data_comanda) as "Ultima zi a lunii" FROM pr_comenzi;

SELECT TO_NUMBER(telefon) as "Numarul de telefon" FROM pr_clienti;

SELECT NVL(email, 'N/A') as "Email" FROM pr_clienti;

SELECT COUNT(*) as "Numarul de masini" FROM pr_masini;

SELECT SUM(valoare) as "Valoarea totala a platilor" FROM pr_plati;

SELECT MAX(an_fabricatie) as "Cel mai nou model" FROM pr_masini;

SELECT id_comanda, id_client, LEVEL FROM pr_comenzi
CONNECT BY PRIOR id_comanda = id_client - 1
START WITH id_comanda = 1;

SELECT id_comanda, id_client, LEVEL FROM pr_comenzi
CONNECT BY id_comanda = PRIOR id_client - 1
START WITH id_comanda = 2;

SELECT marca, model, DECODE(marca, 'Toyota', 'Fiabila', 'Nu este fiabila') as fiabilitate_masina
FROM pr_masini;

SELECT marca, model,
CASE
WHEN an_fabricatie < 2014 THEN 'Masina veche'
WHEN an_fabricatie < 2000 THEN 'Masina foarte veche'
ELSE 'Masina noua'
END as tip_masina
FROM pr_masini;

CREATE VIEW pr_masini_vanzatori AS
SELECT m.marca, m.model, v.nume AS vanzator
FROM pr_masini m
INNER JOIN pr_vanzatori v ON m.id_vanzator = v.id_vanzator;

CREATE INDEX idx_clienti_nume ON pr_clienti(nume);

CREATE SEQUENCE seq_comenzi 
START WITH 1 INCREMENT BY 1
MINVALUE 1
MAXVALUE 99 NOCYCLE;