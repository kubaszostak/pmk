unit PmkResStr;

interface

resourcestring
  sVersion = 'Wersja: %s';
  sCount = 'Ilo��: %d';
  sAppDsc = 'Program do oblicze� przemiescze� pionowych.';

  emNotSupported = 'Ta opcja jescze nie dzia�a';
  emCantConnectToExcel = 'Nie mo�na pol�czyc sie z programem Microsoft Excel';

  dmSaveChanges = 'Zapisa� zmiany?';
  dmDeleteObs = 'Usun�� wszystkie obserwacje z "%s"?';

  // Cycles
  dmDeleteCycle = 'Usun�� "%s"?';
  dmEmptyTable = 'Usun�� wszystkie dane z tabeli?';
  emNoCycleName = 'Nie znaleziono cyklu "%s".';
  emDeleteCykl1 = 'Nie mo�na usun�� cyklu wyj�ciowego.';
  emCycleExists = 'Cykl o nazwie "%s" ju� istnieje.';
  emNoCalcCycle = 'Nie wskazano cyklu pomiarowego dla kt�rego nale�y wykona� obliczenia';
  emCantCalcCycle0 = 'Nie mo�na wykona� oblicze� dla cyklu wyj�ciowego';
  emNotEnoughObs = 'Za ma�o obserwacji.';
  emNotEnoughCycles = 'Za ma�o cykli pomiarowych. Do obliczania przemiescze� musz� by� podane przynajmniej dwa cykle pomiarowe.';
  emCantCopyDhObs = 'Nie mo�na kopiowa� danych do cyklu wyj�ciowego';
  emNoFixedPoints = 'Nie mo�na stworzy� listy punkt�w przeznaczonych na punkty odniesienia.';
  emNoFixedHPoints = 'Przed obliczeniem przemieszcze� na podstawie niezale�nych sieci r�nic wysoko�ci h i h'' nale�y pda� rz�dne reper�w sta�ych';

  emSameBeginEndPoint = 'Punkt pocz�tkowy i ko�cowy musz� si� r�ni�';
  emMaxPointCount = 'Maksymalna ilo�� punkt�w wynosi %d';

  // Process messages
  pmCheckObservations = 'Sprawdzanie poprawno�ci danych obserwacyjnych...';
  pmCheckFunctionData = 'Sprawdzanie definicji wektor�w funkcyjnych...';
  pmGetMemory = 'Przydzielanie pami�ci...';
  pmFreeMemory = 'Zwalnianie pami�ci...';
  pmLoadFunctionData = 'Tworzenie macierzy wektor�w funkcyjnych...';
  pmLoadObservations = 'Tworzenie uk�adu r�wnia� poprawek...';
  pmLoadData = '�adowanie danych...';
  pmCheckData = 'Sprawdzanie poprawno�ci danych...';
  pmCalc = 'Obliczenia...';
  pmSaveResults = 'Zapisywanie wynik�w oblicze�...';

  pmGenerateObservations = 'Generowanie obserwacji...';

  // Creator
  cmMovementInfo = 'Informacje';
  cmSelectCycle = 'Cykl pomiarowy';
  cmInitialization = 'Inicjalizacja oblicze�';
  cmErrors = 'B��dy i ostrze�enia';
  cmSelectFixedPionts = 'Wyb�r punkt�w odniesienia';
  cmCalcFixedPionts = 'Weryfikacja sta�o�ci punkt�w odniesienia';
  cmFixedPointsGroup = 'Grupa punkt�w tworz�ca uk�ad odniesienia';
  cmEstimationType = 'Typ wyr�wnania';
  cmEstimation = 'Obliczenia';
  cmEnd = 'Koniec oblicze�';
  cmFreeEstInfo = 'Podczas wyr�nania nast�pi jednoczesna transformacja '
    +'przemiescze� pionowych na uk�ad okre�lony przez zbi�r punkt�w odniesienia. ';
  cmFixedEstInfo = 'Wyr�wnanie zostanie wykonane z za�o�eniem bezb��dno�ci '
    +'zidentyfikowanych punkt�w odniesienia.';

  emGenRepCount = 'Ilo�� reper�w nie mo�e by� mniejsza od 3';
  emGenLowFixedPointGroupCount = 'Ilo�� grup reper�w sta�ych nie mo�e by� mniejsza od 2';
  emGenFixedPointCount = 'Przy podanej ilo�ci grup reper�w odniesienia minimalna ilo�� reper�w sta�ych wynosi %d';


implementation

end.
