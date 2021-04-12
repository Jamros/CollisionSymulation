# CollisionSymulation
Symulacja kolizji w wielowęzłowych sieciach ISM

Założeniem projektu jest symulacja kolizji pakietów w wielowęzłowych sieciach ISM, uwzględniając ich typ, czas trwania oraz ich ilośc.

Pełna symulacja wielowęzłowej sieci pracującej w pasmie ISM, to bardzo czasochłonne i złożone zadanie. Wymaga ono wzięcia pod uwagę, wszystkich zależności fizycznych, czasowych oraz specyfiki danego protokołu. Wykracza to znacząco ponad wymagania pracy magisterskiej, dlatego wykonano uproszczoną symulację takiej sieci. Założono, że wymagane parametry badanej sieci oraz zastosowanych wzorców czasu, to:

  a) czas startu transmisji,
  
  b) czas zakończenia transmisji,
  
  c) 3 główne parametry oscylatorów kwarcowych wpływających na ich częstotliwość (tolerancja częstotliwości, współczynnik temperaturowy oraz współczynnik starzeniowy)

Struktura projektu
1.  CreatedSignals.m - m-plik odpowiedzialny za generowanie danych o sieci

  a) Wstepne założenia:
  
    • Parametry wzorca czasu nie zmieniają się w czasie transmisji (innymi słowy, czas końca transmisji zawsze będzie sumą momentu startu oraz czasu trwania pakietu).
    • W sieci pracuje tylko jedna stacja bazowa, w której zasięgu znajdują się wyłącznie symulowane urządzenia.
    • Transmitery nadają synchronicznie, co określony przedział czasu.
    • Wiadomości przesyłane w sieci wykorzystują całą przepustowość kanału (koniec transmisji jednego urządzenia sieciowego oznacza rozpoczęcie wysyłania nowego komunikatu następnego urządzenia końcowego)
    • Do każdego wygenerowanego czasu startu, dodano poprawkę uwzględniająca odchylenie częstotliwości wzorca czasu.
    • Do losowania parametrów, wykorzystano funkcje rand () czyli rozkład równomierny.
    • Zaniechanie obsługi współczynnika temperaturowego oraz starzeniowego.
    
  b) Parametry wejściowe:
  
    • Ilość urządzeń końcowych (DeviceNumbers).
    • Czas trwania transmisji [w ms] (TimeTransmision).
    • Zakres obserwowanych slotów czasowych [wektor 2-elementowy] (SlotsTimes).
    • Zakres tolerancji częstotliwości [w ppm] (ToleranceRange).
    • Częstotliwość pracy wzorca czasowego [kHz] (OscilatorFrequence).
    
  c) Wartości zwracane:
  
    • Czas startu oraz stopu [ms] w postaci tablicy 3-wymiarowej o wielkości „DeviceNumbers” x 2 x Czas obserwacji (SlotsTimes (2) - SlotsTimes (1)),
    • Wektor „DeviceNumbers „-elementowy zawierający wygenerowane tolerancję częstotliwości.

2. OverlapTransmision.m - m-plik odpowiedzialny za analize kolizyjności w sieci

  a)Wstępne założenia:
  
    • Detekcja nakładania się czasów transmisji.
    • Rozróżnianie awarii lewostronnych od prawostronnych.
    • Zliczanie ilości wystąpień zakłóceń wspominanego typu.
    • Określanie maksymalnego czasu trwania kolizji dwojakiego rodzaju.
    • Zakres porównawczy czasów transmisji zależy od aktualnie badanego slotu czasowego (zmniejszenie ilości wymaganych porównań
    
  b) Parametry wejściowe:
  
    • Tablica 3-wymiarowa zawierająca czasy startu / stopu transmisji zwracane przez funkcję generującą dane do sieci opisaną w rozdziale (4.2.1).
    • Czas trwania transmisji [w ms] (TimeTransmision).
    • Ilość urządzeń końcowych (DeviceNumbers).
    • Zakres obserwowanych slotów czasowych [wektor 2-elementowy] (SlotsTimes).
    
  c) Wartości zwracane:
  
    • Wyniki są zapisane w 4-wymiarowej tablicy o wielkości „DeviceNumbers” x „DeviceNumbers” x „SlotsTimes (2)” x 4. 
   Taki układ pozwala na zamieszczenie wszystkich niezbędnych informacji w poszczególnych wymiarach, które odpowiadają za:
   
    1. Numer transmitera zakłócającego (1 – DeviceNumbers).
    2. Numer transmitera zakłócanego (1 – DeviceNumbers).
    3. Numer slotu czasowego (1 - SlotsTimes (2)”).
    4. Ilość wystąpień kolizji lewostronnych (1) oraz prawostronnych (2), maksymalny czas zakłóceń lewostronnych (3) oraz prawostronnych (4).

3. OverlapingPlotDisplay.m - m.plik odpowiedzialny za obliczenie oraz przedstawienie wyników w formie graficznej
