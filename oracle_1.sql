CREATE TABLE Menadzer (
    id_menadzera NUMBER PRIMARY KEY,
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100)
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

CREATE TABLE Klub (
    id_klubu NUMBER PRIMARY KEY,
    nazwa VARCHAR2(100),
    id_menadzera NUMBER,
    CONSTRAINT fk_klub_menadzer FOREIGN KEY (id_menadzera) REFERENCES Menadzer(id_menadzera)
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

CREATE TABLE Zawodnicy (
    id_zawodnika NUMBER PRIMARY KEY,
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100),
    id_klubu NUMBER,
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

--procedury

CREATE OR REPLACE PROCEDURE dodaj_menadzera (
    p_imie      IN VARCHAR2,
    p_nazwisko  IN VARCHAR2
)
AS
BEGIN
    INSERT INTO Menadzer (id_menadzera, imie, nazwisko)
    VALUES (seq_menadzer.NEXTVAL, p_imie, p_nazwisko);
END;

CREATE OR REPLACE PROCEDURE dodaj_klub (
    p_nazwa IN VARCHAR2,
    p_id_menadzera IN NUMBER
) AS
BEGIN
    INSERT INTO Klub (id_klubu, nazwa, id_menadzera)
    VALUES (seq_klub.NEXTVAL, p_nazwa, p_id_menadzera);
END;

CREATE OR REPLACE PROCEDURE dodaj_zawodnika (
    p_imie IN VARCHAR2,
    p_nazwisko IN VARCHAR2,
    p_id_klubu IN NUMBER
) AS
BEGIN
    INSERT INTO Zawodnicy (id_zawodnika, imie, nazwisko, id_klubu)
    VALUES (seq_zawodnik.NEXTVAL, p_imie, p_nazwisko, p_id_klubu);
END;

CREATE OR REPLACE PROCEDURE dodaj_statystyki (
    p_id_zawodnika IN NUMBER,
    p_gole IN NUMBER,
    p_asysty IN NUMBER,
    p_zolte IN NUMBER,
    p_czerwone IN NUMBER,
    p_ilosc_meczy IN NUMBER
) AS
BEGIN
    INSERT INTO Statystyki_zawodnika (
        id_statystyk, id_zawodnika, ilosc_goli, ilosc_asyst, ilosc_zoltych_kartek, ilosc_czerwonych_kartek, ilosc_meczy
    )
    VALUES (
        seq_statystyki.NEXTVAL, p_id_zawodnika, p_gole, p_asysty, p_zolte, p_czerwone, p_ilosc_meczy
    );
END;

BEGIN
    dodaj_menadzera('Tomek', 'Nowak');
    dodaj_klub('FC Oracle', 1);
    dodaj_zawodnika('Pawe?', 'Kowalczyk', 1);
    dodaj_statystyki(1, 10, 5, 2, 0);
END;

select * from menadzer;
select * from klub;
select * from zawodnicy;
select * from Statystyki_zawodnika;

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
