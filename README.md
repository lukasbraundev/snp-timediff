# snp-timediff
DHBW Exam in ASM


**Programmentwurf**
**Systemnahe Programmierung**
**Kurs TIT 20**

### Bearbeitungshinweise

Die Prüfungsleistung für die Vorlesung Systemnahe Programmierung wird durch einen Programmentwurf in Intel x86- 64 Assembler für den NASM Assembler un-ter dem Betriebssystem Linux erbracht. Andere Programmiersprachen sowie C-Bibliotheksfunktionen in Assemblerprogrammen dürfen nicht verwendet wer-den, außer dies ist in der Aufgabenstellung ausdrücklich gefordert. **Der Programmentwurf wird gruppenweise erstellt (max. drei Studierende pro Gruppe)**. Die Namen der Gruppenmitglieder sind im Quellcode zu vermer-ken. Außerdem ist zu vermerken, welches Gruppenmitglied welche Aufgabentei-le überwiegend bzw. schwerpunktmäßig bearbeitet hat.
Wenn Sie Programmfragmente aus der Literatur, dem Internet oder von anderen Quellen verwenden, ist die Quelle als Kommentar kenntlich zu machen.

### Bewertung und Abgabe
Der Aufgaben werden anhand der folgenden Kriterien bewertet:

- Funktionalität, Korrektheit und Effizienz
- Verständlichkeit, Kommentierung, Strukturierung

Der Programmentwurf ist jeweils einmal pro Gruppe als „gezipptes“ Archiv im tar-Format bis spätestens

```Donnerstag, 14. April 2022, 23:59 CEST```

per Email an rdrcode@gmx.eu sowie in Kopie an das Sekretariat Informations-technik, Fr. Schmidt zu schicken. Abzugeben sind der vollständige Quellcode, das Makefile sowie das ausführbare Programm.

Beachten Sie bitte, dass Sie für die Vollständigkeit und Lesbarkeit des abgegebe-nen Quellcodes verantwortlich sind. Der Name der abzugebenden Archivdatei ist `pe_tit 20 _nachname1_nachname2_nachname3.tar.gz`.

### Aufgabenstellung

Schreiben Sie ein Assembler-Programm timediff, welches eine Folge aufstei-
gend sortierter Zeitstempel einliest und für jeden Zeitstempel die Zeitdifferenz 
zu dessen Vorgänger ausgibt.

- Die Eingabe erfolgt zeilenweise von der Standardeingabe als formatierter ASCII-Text.
- Gültige Eingabezeilen enthalten genau einen Zeitstempel.
- Eingabezeilen werden durch einen Zeilenumbruch abgeschlossen.
- Die Ausgabe erfolgt auf der Standardausgabe. Die Anzahl der Sys-tem-Call Aufrufe (hier System-Call `write`) ist zu minimieren.
- Eingabezeilen werden nicht ausgegeben.
- Die Ausgabe erfolgt erst, nachdem der Eingabetext vollständig eingelesen wurde.
- Ein Eingabetext kann maximal 10000 Zeitstempel enthalten.
- Ein gültiger Zeitstempel wird im Format `S+.M+` angegeben, wobei `S` die Anzahl Sekunden seit der UNIX Epoche angibt und `M` die Anzahl Mikrosekunden seit Sekundenbeginn. `S` und `M` sind Dezimalziffern im ASCII-Format.
- Ein Zeitstempel ist in eine Struktur des Typs `struct timeval` zu konvertieren (Definition siehe `man 2 gettimeofday`).
- Wenn eine Eingabezeile einen ungültigen Zeitstempel enthält, dann beendet sich das Programm mit einer entsprechenden Fehlermeldung.
- Der Sekundenanteil eines Zeitstempels ist bei der Eingabe vorzeichenlos und mindestens einstellig mit einem maximalen Wertebereich von 64 Bit.
- Der Mikrosekundenanteil eines Zeitstempels ist bei der Eingabe grundsätzlich auf sechs Stellen zu normieren, d.h. der Mikrosekundenanteil des Zeitstempels `1502736311.5` ist `500000`.
- Die konvertierten Zeitstempel werden in einer Liste gespeichert.
- Das Modul Liste implementiert mindestens die in der Datei `list.asm` vordefinierten Funktionen.
- Die Datei `list_test.c` definiert den Modultest für das Modul Liste.
- Für die Ausgabe werden die Zeitstempel aus der Liste ausgelesen.
- Die Ausgabe der Zeitstempel und der Zeitdifferenzen muss dem Format des unten aufgeführten Beispiels entsprechen.


### Beispiel einer Eingabefolge:

```
1000000000.0
1234567890.000000
1483225200.000000
1491861600.000
1500000000.000000
1502529000.000001
1502529001.000000
1502530860.999999
1502617201.999998
1502617202.000000
1502736311.000001
```

### Format für die Ausgabe:

```
1000000000.000000
=======
1234567890.000000
2714 days, 20:44:50.000000
=======
1483225200.000000
2877 days, 23:28:30.000000
=======
1491861600.000000
100 days, 00:00:00.000000
=======
1500000000.000000
94 days, 04:40:00.000000
=======
1502529000.000001
29 days, 06:30:00.000001
=======
1502529001.000000
00:00:00.999999
=======
1502530860.999999
00:30:59.999999
=======
1502617201.999998
23:59:00.999999
=======
1502617202.000000
00:00:00.000002
=======
1502736311.000001
1 day, 09:05:09.000001
```