PROJEKT RBD

Projekt rozproszonej bazy danych powinien zawierać opracowaną strukturę składającą się z części baz umieszczonych na kilku serwerach w środowisku heterogenicznym (np. w środowisku dwóch serwerów MS SQLServer oraz serwera Oracle). Projekt rozproszonej bazy danych powinien zawierać:

1. Opracowanie struktury RBD (podział obiektów w tym tabel, procedur, widoków) na różne serwery w środowisku rozporoszonym oraz opis uzasadnienia tego podziału.

2. Wykorzystanie zapytań AD HOC – funkcja OPENROWSET w dostępie do zdalnych źródeł danych z przetwarzaniem danych po stronie serwera zdalnego i serwera lokalnego:

    - dostęp SQLServer – SQLServer

    - dostęp SQLServer – ORACLE  

    - dostęp SQLServer – Access 

    - dostęp SQLServer – *.xls   

 - wielodostęp w dowolnej konfiguracji SQLServer - ORACLE_Access, *.xls (sprzeganie jednoocześnie różnych źródeł danych) 

- dostęp do zdalnych źródeł powinien odbywać się przez pisanie widoków i procedur rozproszonych (rzutowanie różnych typów danych i posługiwanie się funkcjami agregującymi zdalnymi i lokalnymi)

- przetwarzanie zdalne i lokalne w widokach i procedurach

3. Ustanawiania serwerów połączonych (linkowanie zdalnych serwerów) w środowisku SQLServer oraz mapowania praw loginu lokalnego na prawa loginu zdalnego (funkcje sprawdzające źródła zdalne i ich konfigurację) :

    - linkowanie serwerów: SQLServer – SQLServer

    - linkowanie serwerów:  SQLServer – ORACLE (tylko od strony SQL Server do Oracle) 

    - linkowanie serwerów:  SQLServer – Access

    - linkowanie serwerów:  SQLServer – *.xls  

 - dostęp do zdalnych źródeł powinien odbywać się przez pisanie widoków i procedur rozproszonych  przy ustanowionych serwerach zdalnych (wielodostęp w środowiskach heterogenicznych)

 4. Pisanie (przy ustanowionym serwerze połączonym) zapytań przekazujących– (przetwarzanie lokalne i zdalne danych) w tym z zastosowaniem funkcji: OPENQUERY

5. Wstawianie i modyfikowanie danych na zdalnych źródłach danych z poziomu ustanowionego serwera połączonego
