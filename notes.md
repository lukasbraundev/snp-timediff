# Notizen

## Besprechung

- Input muss verändert werden
  - Antwort von Reitemann gekommen
  - `STDIN`-Einlesen (wie in `wordcount`) und nicht Custom-Eingabe mit F
- `list_init` noch zu klären
- falsche Beispiel-Werte noch zu klären
- genauer Ablaufplan des gesammten Programms aus Sicht von `timediff.asm`: [draw.io](https://drive.google.com/file/d/1Wl6g83kBaOla6sCmQAScJ3gezRkNV2cx/view?usp=sharing)
  - Output-Formatierung fehlt noch

Aufteilung: 

- LK: Input + Exit Funktionen
  - `STDIN` einlesen
  - Eingabe validieren
  - Konvertierung in timeval (`ASCII_to_timeval.asm`)
  - Exit Funktionen als Error-Handler (`timediff.asm`)
- JB: List Funktionen
  - `list.asm` komplett
  - noch warten auf Antwort wegen init
- HS: Output Funktionen
  - Berechung Differenz
  - Konvertierung in ASCII (`timeval_to_ASCII.asm`)
  - Output

**Aufgaben wenn möglich fertig bis 15:00 Sonntag**