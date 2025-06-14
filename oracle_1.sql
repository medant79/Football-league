CREATE TABLE Klub (
    id_klubu NUMBER PRIMARY KEY,
    nazwa VARCHAR2(100),
    CONSTRAINT unikalna_nazwa_klubu UNIQUE (nazwa)
);

CREATE SEQUENCE seq_klub START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_klub_bi
BEFORE INSERT ON Klub
FOR EACH ROW
BEGIN
    IF :NEW.id_klubu IS NULL THEN
        SELECT seq_klub.NEXTVAL INTO :NEW.id_klubu FROM dual;
    END IF;
END;

CREATE TABLE Menadzer (
    id_menadzera NUMBER PRIMARY KEY,
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100),
    data_urodzenia DATE,
    id_klubu NUMBER,
    CONSTRAINT fk_menadzer_klub FOREIGN KEY (id_klubu) REFERENCES Klub(id_klubu)
);

CREATE SEQUENCE seq_menadzer START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_menadzer_bi
BEFORE INSERT ON Menadzer
FOR EACH ROW
BEGIN
    IF :NEW.id_menadzera IS NULL THEN
        SELECT seq_menadzer.NEXTVAL INTO :NEW.id_menadzera FROM dual;
    END IF;
END;

CREATE TABLE Zawodnicy (
    id_zawodnika NUMBER PRIMARY KEY,
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100),
    id_klubu NUMBER,
    data_urodzenia DATE,
    CONSTRAINT fk_zawodnik_klub FOREIGN KEY (id_klubu) REFERENCES Klub(id_klubu)
);

CREATE SEQUENCE seq_zawodnik START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_zawodnik_bi
BEFORE INSERT ON Zawodnicy
FOR EACH ROW
BEGIN
    IF :NEW.id_zawodnika IS NULL THEN
        SELECT seq_zawodnik.NEXTVAL INTO :NEW.id_zawodnika FROM dual;
    END IF;
END;

CREATE TABLE Statystyki_zawodnika (
    id_statystyk NUMBER PRIMARY KEY,
    id_zawodnika NUMBER UNIQUE,
    ilosc_goli NUMBER,
    ilosc_asyst NUMBER,
    ilosc_zoltych_kartek NUMBER,
    ilosc_czerwonych_kartek NUMBER,
    ilosc_meczy NUMBER,
    CONSTRAINT fk_statystyki_zawodnika FOREIGN KEY (id_zawodnika) REFERENCES Zawodnicy(id_zawodnika)
);

CREATE SEQUENCE seq_statystyki START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_statystyki_bi
BEFORE INSERT ON Statystyki_zawodnika
FOR EACH ROW
BEGIN
    IF :NEW.id_statystyk IS NULL THEN
        SELECT seq_statystyki.NEXTVAL INTO :NEW.id_statystyk FROM dual;
    END IF;
END;

--triggery

CREATE OR REPLACE TRIGGER trg_auto_statystyki_ai
AFTER INSERT ON Zawodnicy
FOR EACH ROW
BEGIN
    INSERT INTO Statystyki_zawodnika (
        id_statystyk,
        id_zawodnika,
        ilosc_goli,
        ilosc_asyst,
        ilosc_zoltych_kartek,
        ilosc_czerwonych_kartek,
        ilosc_meczy
    ) VALUES (
        seq_statystyki.NEXTVAL,
        :NEW.id_zawodnika,
        0,
        0,
        0,
        0,
        0
    );
END;

CREATE OR REPLACE TRIGGER unikaj_duplikatow_zawodnikow
BEFORE INSERT ON Zawodnicy
FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM Zawodnicy
    WHERE imie = :NEW.imie AND nazwisko = :NEW.nazwisko AND data_urodzenia = :NEW.data_urodzenia;

    IF cnt > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Taki zawodnik już istnieje!');
    END IF;
END;

CREATE OR REPLACE TRIGGER unikaj_duplikatow_menadzerow
BEFORE INSERT ON Menadzer
FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM Menadzer
    WHERE imie = :NEW.imie AND nazwisko = :NEW.nazwisko AND data_urodzenia = :NEW.data_urodzenia;

    IF cnt > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Taki menadzer już istnieje!');
    END IF;
END;

--procedury

CREATE OR REPLACE PROCEDURE dodaj_klub (
    p_nazwa IN VARCHAR2
) AS
BEGIN
    INSERT INTO Klub (id_klubu, nazwa)
    VALUES (seq_klub.NEXTVAL, p_nazwa);
END;

CREATE OR REPLACE PROCEDURE dodaj_menadzera(
    p_imie IN VARCHAR2,
    p_nazwisko IN VARCHAR2,
    p_data_urodzenia IN DATE,
    p_nazwa_klubu IN VARCHAR2
) AS
    v_id_klubu NUMBER;
BEGIN
    SELECT id_klubu INTO v_id_klubu
    FROM Klub
    WHERE LOWER(nazwa) = LOWER(p_nazwa_klubu);

    INSERT INTO Menadzer(id_menadzera, imie, nazwisko, data_urodzenia, id_klubu)
    VALUES (seq_menadzer.NEXTVAL, p_imie, p_nazwisko, p_data_urodzenia, v_id_klubu);
END;

CREATE OR REPLACE PROCEDURE zmien_klub_menadzera(
    p_imie IN VARCHAR2,
    p_nazwisko IN VARCHAR2,
    p_data_urodzenia IN DATE,
    p_nowa_nazwa_klubu IN VARCHAR2
) AS
    v_id_klubu NUMBER;
BEGIN
    SELECT id_klubu INTO v_id_klubu
    FROM Klub
    WHERE LOWER(nazwa) = LOWER(p_nowa_nazwa_klubu);

    UPDATE Menadzer
    SET id_klubu = v_id_klubu
    WHERE LOWER(imie) = LOWER(p_imie)
      AND LOWER(nazwisko) = LOWER(p_nazwisko)
      AND data_urodzenia = p_data_urodzenia;
END;

CREATE OR REPLACE PROCEDURE dodaj_zawodnika (
    p_imie IN VARCHAR2,
    p_nazwisko IN VARCHAR2,
    p_data_ur DATE,
    p_nazwa_klubu IN VARCHAR2
) AS
    v_id_klubu NUMBER;
BEGIN
    SELECT id_klubu INTO v_id_klubu
    FROM Klub
    WHERE LOWER(nazwa) = LOWER(p_nazwa_klubu);

    INSERT INTO Zawodnicy (id_zawodnika, imie, nazwisko, data_urodzenia, id_klubu)
    VALUES (seq_zawodnik.NEXTVAL, p_imie, p_nazwisko, p_data_ur, v_id_klubu);
END;

CREATE OR REPLACE PROCEDURE przenies_zawodnika(
    p_imie VARCHAR2,
    p_nazwisko VARCHAR2,
    p_data_ur DATE,
    p_nazwa_klubu VARCHAR2
) IS
    v_id_klubu NUMBER;
BEGIN
    SELECT id_klubu INTO v_id_klubu
    FROM Klub
    WHERE LOWER(nazwa) = LOWER(p_nazwa_klubu);

    UPDATE Zawodnicy
    SET id_klubu = v_id_klubu
    WHERE imie = p_imie AND nazwisko = p_nazwisko AND data_urodzenia = p_data_ur;
END;

CREATE OR REPLACE PROCEDURE aktualizuj_statystyki (
    p_id_zawodnika NUMBER,
    p_gole NUMBER,
    p_asysty NUMBER,
    p_zolte NUMBER,
    p_czerwone NUMBER,
    p_mecze NUMBER
) IS
BEGIN
    UPDATE Statystyki_zawodnika
    SET 
        ilosc_goli = ilosc_goli + p_gole,
        ilosc_asyst = ilosc_asyst + p_asysty,
        ilosc_zoltych_kartek = ilosc_zoltych_kartek + p_zolte,
        ilosc_czerwonych_kartek = ilosc_czerwonych_kartek + p_czerwone,
        ilosc_meczy = ilosc_meczy + p_mecze
    WHERE id_zawodnika = p_id_zawodnika;
END;

--testy
BEGIN
    dodaj_klub('Real Madrid');
    dodaj_klub('Barcelona');
END;
SELECT * FROM Klub;

BEGIN
    dodaj_menadzera('Carlo', 'Ancelotti', TO_DATE('1959-06-10','YYYY-MM-DD'), 'Real Madrid');
END;

BEGIN
    zmien_klub_menadzera('Carlo', 'Ancelotti', TO_DATE('1959-06-10','YYYY-MM-DD'), 'Barcelona');
END;

SELECT * FROM Menadzer;

BEGIN
    dodaj_zawodnika('Luka', 'Modric', TO_DATE('1985-09-09','YYYY-MM-DD'), 'Real Madrid');
END;
SELECT * FROM Zawodnicy;
SELECT * FROM Statystyki_zawodnika;

BEGIN
    przenies_zawodnika('Luka', 'Modric', TO_DATE('1985-09-09','YYYY-MM-DD'), 'Barcelona');
END;

SELECT * FROM Zawodnicy;

BEGIN
    aktualizuj_statystyki(1, 2, 1, 1, 0, 1); -- 2 gole, 1 asysta, 1 żółta kartka, 0 czerwonych, 1 mecz
END;

SELECT * FROM Statystyki_zawodnika;

--funkcje

CREATE OR REPLACE FUNCTION srednia_goli_na_mecz(p_id_zawodnika IN NUMBER)
RETURN NUMBER IS
    v_gole NUMBER;
    v_mecze NUMBER;
BEGIN
    SELECT ilosc_goli, ilosc_meczy
    INTO v_gole, v_mecze
    FROM Statystyki_zawodnika
    WHERE id_zawodnika = p_id_zawodnika;

    IF v_mecze = 0 THEN
        RETURN 0;
    ELSE
        RETURN v_gole / v_mecze;
    END IF;
END;

CREATE OR REPLACE FUNCTION srednia_asyst_na_mecz(p_id_zawodnika IN NUMBER)
RETURN NUMBER IS
    v_asyste NUMBER;
    v_mecze NUMBER;
BEGIN
    SELECT ilosc_asyst, ilosc_meczy
    INTO v_asyste, v_mecze
    FROM Statystyki_zawodnika
    WHERE id_zawodnika = p_id_zawodnika;

    IF v_mecze = 0 THEN
        RETURN 0;
    ELSE
        RETURN v_asyste / v_mecze;
    END IF;
END;

CREATE OR REPLACE FUNCTION srednia_zoltych_kartek_na_mecz(p_id_zawodnika IN NUMBER)
RETURN NUMBER IS
    v_zolte_kartki NUMBER;
    v_mecze NUMBER;
BEGIN
    SELECT ilosc_zoltych_kartek, ilosc_meczy
    INTO v_zolte_kartki, v_mecze
    FROM Statystyki_zawodnika
    WHERE id_zawodnika = p_id_zawodnika;

    IF v_mecze = 0 THEN
        RETURN 0;
    ELSE
        RETURN v_zolte_kartki / v_mecze;
    END IF;
END;

CREATE OR REPLACE FUNCTION srednia_czerwonych_kartek_na_mecz(p_id_zawodnika IN NUMBER)
RETURN NUMBER IS
    v_czerwone_kartki NUMBER;
    v_mecze NUMBER;
BEGIN
    SELECT ilosc_czerwonych_kartek, ilosc_meczy
    INTO v_czerwone_kartki, v_mecze
    FROM Statystyki_zawodnika
    WHERE id_zawodnika = p_id_zawodnika;

    IF v_mecze = 0 THEN
        RETURN 0;
    ELSE
        RETURN v_czerwone_kartki / v_mecze;
    END IF;
END;

SELECT srednia_goli_na_mecz(1) AS srednia FROM dual;
