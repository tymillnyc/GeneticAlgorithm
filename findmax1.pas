program findMax2000;

const
  WordMaxValue = 65335;
  eps = 1 / 16384;
  N = 10;

type
  RealArray = array of Real;

var
  f1: text;
  population: RealArray;
  screschCount, iterCount, iterNumberWhenMax: integer;
  isPrintToScreen: integer = 0;
  mutationCount: integer; //количество мутаций
  porog, maxOsob, probobilityScresch: real;
  mode: integer; //режим(0 - основной, 1 - тестовый)
  mutationProbability: real;//вероятность мутации
  prevMax, prevF: real;

function F(x: real): real;
begin
  F := x * power(x - 1.1, 5) * power(x - 1.2, 4) * power(x - 1.3, 3) * cos(x + 100);
end;

{перевод real в эквивалентный вид для битовых операций}
function RealXToBit(x: real): word;
begin
  RealXToBit := trunc(x / 4 * WordMaxValue);
end;

{обратная операция}
function BitXToReal(x: word): real;
begin
  BitXToReal := x * 4 / WordMaxValue;
end;

{перевод в двоичный код}
function wordTo2(x: word): string;
var
  i: integer;
  s: string;
  a: word;
begin
  s := '';
  a := x;
  while a > 0 do
  begin
    s := chr(ord('0') + (a mod 2)) + s;
    a := a div 2;
  end;
  for i := 1 to 16 - length(s) do
    s := '0' + s;
  wordTo2 := s; 
end;



{генерация начальной популяции}
function createInitialPopulation(count: integer): RealArray;
var
  populMassiv: RealArray;
  i: integer;
begin
  setLength(populMassiv, count);
  for i := 0 to count - 1 do 
    populMassiv[i] := 4 * random;
  createInitialPopulation := populMassiv;
end;
{поиск максимальной особи}
function findMaxOsob(population: RealArray): real;
var
  i: integer;
  maxOsob: real;
begin
  maxOsob := population[0];
  for i := 1 to length(population) - 1 do
    if F(population[i]) > F(maxOsob) then
      maxOsob := population[i];
  findMaxOsob := maxOsob;
end;
{критерий останова}
function isStopByCriterion(maxOsob, porog, eps: real): boolean;
var
  result1: boolean;
begin
  result1 := abs(F(maxOsob)-porog) <= eps;
  isStopByCriterion := result1;
  //writeln('isStopByCriterion=', result1, ' x=', maxOsob:0:6, ' F= ', F(maxOsob):0:6, ' porog=', porog:0:6);
end;

procedure PrintIterationNumber(iterNumber: integer);
begin
  if mode = 0 then exit;
  writeln(f1, '                          |-----------------------------------|');
  writeln(f1, '                          |--текущий номер итерации: ', iterNumber, '--------|');
  writeln(f1, '                          |-----------------------------------|');
  writeln(f1, ' ');
end;

procedure PrintPopulation(population: RealArray; iterNumber: integer);
var
  i: integer;
  sa: word;
  s: string;
begin
  if mode = 0 then exit;
  for i := 0 to length(population) - 1 do
  begin
    sa := RealXToBit(population[i]);
    s := wordTo2(sa);
    writeln(f1, 'аргумент в разных представлениях = ', population[i]:0:6, '; = ', sa, '; = ', s, ' значение = ', F(population[i]):0:6);
  end;
  if isPrintToScreen = 1 then
  begin
    writeln('текущий номер итерации: ', iterNumber);
    for i := 0 to length(population) - 1 do
      writeln('аргумент = ', population[i]:0:6, ' значение = ', F(population[i]):0:6);
  end;
end;

procedure PrintResult(maxOsob: real; iterCount: integer);
begin
  if (mode = 0) or (isPrintToScreen = 1) then
    writeln('результат: x = ', maxOsob:0:6, ' f = ', F(maxOsob):0:6, ' количество итераций = ', iterCount);
  if mode = 1 then
    writeln(f1, 'результат: x = ', maxOsob:0:6, ' f = ', F(maxOsob):0:6, ' количество итераций = ', iterCount);
end;








procedure selection(var population: RealArray; screschCount: integer);
var
  selectionLength: integer = 0;
  count, i, j: longint;
  populationLength: integer;
  fractionalPart: real; 
  FAvg: real = 0;
  sel, FPopulation: RealArray;
begin
  if mode = 1 then
  begin
    writeln(f1, '                          |-----------------------------------|');
    writeln(f1, '                          |-----ОПЕРАЦИЯ СЕЛЕКЦИИ.НАЧАЛО.-----|');
    writeln(f1, '                          |-----------------------------------|');
  end;
  populationLength := length(population);
  count := 0;
  fractionalPart := 0;
  setLength(FPopulation, populationLength);
  if mode = 1 then writeln(f1, '--------------------------------------');
  {рассчет Fi особи}
  for i := 0 to populationLength - 1 do 
  begin
    FPopulation[i] := F(population[i]) + 1000000;
    if mode = 1 then writeln(f1, 'значение F', i, ' особи = ', FPopulation[i]);
  end;
  if mode = 1 then writeln(f1, '--------------------------------------');
  {рассчет среднего значения(Fср)}
  for i := 0 to populationLength - 1 do 
    FAvg := FAvg + FPopulation[i];
  FAvg := FAvg / populationLength;
  if mode = 1 then writeln(f1, 'среднеe значениe особи = ', FAvg);
  if mode = 1 then writeln(f1, '--------------------------------------');
  {вычисление коэффициента особи}
  for i := 0 to populationLength - 1 do
  begin
    FPopulation[i] := FPopulation[i] / FAvg;
    if mode = 1 then writeln(f1, 'коэффииент ', i, ' особи = ', FPopulation[i]);
  end;
  if mode = 1 then writeln(f1, '--------------------------------------');
  for i := 0 to populationLength - 1 do
  begin
    count := trunc(FPopulation[i]);
    fractionalPart := FPopulation[i] - count;///дробная часть
    if fractionalPart > random then count := count + 1;
    selectionLength := selectionLength + count;   
    setLength(sel, selectionLength);
    for j := selectionLength - count to selectionLength - 1 do
      sel[j] := population[i];// sel - промежуточный массив; каждая особь попадает в этот массив в количестве равным коэффициенту
  end;
  populationLength := screschCount * 2;
  setlength(population, populationLength);
  for i := 0 to populationLength - 1 do
  begin
    population[i] := sel[random(length(sel))];
  end;
  // if mode = 1 then 
  //begin
   // for i:=0 to length(population)-1 do
     //writeln(f1, 'какие остались особи после селекции = ',  population[i]:0:6);
  //end;
    //if mode = 1 then writeln(f1, '--------------------------------------');
   {освобождение памяти}
  setLength(FPopulation, 0);
  setLength(sel, 0);
  if mode = 1 then
  begin
    writeln(f1, '                          |-----------------------------------|');
    writeln(f1, '                          |-----ОПЕРАЦИЯ СЕЛЕКЦИИ.КОНЕЦ.------|');
    writeln(f1, '                          |-----------------------------------|');
    writeln(f1, ' ');
  end;
  
end;


procedure printTo2(x1i, x2i: word);
var
  x1s, x2s: string;
begin
  if mode = 0 then exit;
  x1s := wordTo2(x1i);
  x2s := wordTo2(x2i);
  writeln(f1,  x1i, ' ', x2i);
  writeln(f1, 'представление первой в паре особи в двоичном виде: ', x1s, ' и второй: ', x2s);
end;





procedure doScresch(var population: RealArray; screschCount: integer);
var
  point1, point2, i, k: integer;
  x1i, x2i: word;
  x1mid, x2mid: word;
  kRandom: real;
begin
  k := 1;
  if mode = 1 then
  begin
    writeln(f1, '                          |--------------------------------------|');
    writeln(f1, '                          |-----ОПЕРАЦИЯ СКРЕЩИВАНИЯ.НАЧАЛО.-----|');
    writeln(f1, '                          |--------------------------------------|');
  end;
  for i := 1 to screschCount do
  begin
    kRandom := random;
    if mode = 1 then 
    begin
      writeln(f1, '--------------------------------------');
      writeln(f1, k, ' скрещивание');
      writeln(f1, 'вероятность скрещивания, выбранная случайным образом: ', kRandom:0:4);
    end;
    if kRandom > probobilityScresch then 
    begin
      if mode = 1 then
      begin
        writeln(f1, 'скрещиваниe не произошло');
        k := k + 1;
      end;
      continue;
    end;
    if mode = 1 then
    begin
      writeln(f1, 'скрещиваниe произошло');
      k := k + 1;
    end;
    point1 := random(8) + 1;
    point2 := 8 + random(8) + 1;
    if mode = 1 then 
    begin
      writeln(f1, 'особи для скрещивания: ', 2 * i - 2, ' и ', 2 * i - 1);
      writeln(f1, 'точки для скрещивания: point 1 = ', point1, ';  point 2 = ', point2);
    end;
    x1i := RealXToBit(population[2 * i - 2]);
    x2i := RealXToBit(population[2 * i - 1]);
    printTo2(x1i, x2i);
    
    
    
    {промежуток от первой до второй точек для x1}
    x1mid := x1i shl point1;
    x1mid := x1mid shr (16 - point2 + point1);
    x1mid := x1mid shl (16 - point2);
    {промежуток от первой до второй точек для x2}
    x2mid := x2i shl point1;
    x2mid := x2mid shr (16 - point2 + point1);
    x2mid := x2mid shl (16 - point2);
    {передача родительских признаков потомкам}
    x1i := x1i - x1mid + x2mid;
    x2i := x2i - x2mid + x1mid;
    printTo2(x1i, x2i);
    {обратный перевод из целого типа в вещественный}
    population[2 * i - 2] := BitXToReal(x1i);
    population[2 * i - 1] := BitXToReal(x2i);
  end;
  if mode = 1 then
  begin
    writeln(f1, '                          |--------------------------------------|');
    writeln(f1, '                          |-----ОПЕРАЦИЯ СКРЕЩИВАНИЯ.КОНЕЦ.------|');
    writeln(f1, '                          |--------------------------------------|');
    writeln(f1, ' ');
  end;
end;

procedure mutation(var population: RealArray);
var
  i, lRandom: integer;
  k: integer = 0;
  xi, waq: word;
  r: integer;
  wer: string;
  kRandom: real;
begin
  r := 0;
  
  if mode = 1 then
  begin
    writeln(f1, '                          |--------------------------------------|');
    writeln(f1, '                          |-------ОПЕРАЦИЯ МУТАЦИИ.НАЧАЛО.-------|');
    writeln(f1, '                          |--------------------------------------|');
    writeln(f1, ' ');
  end;
  for i := 0 to length(population) - 1 do
  begin
    r := r + 1;
    kRandom := random;
    if mode = 1 then
    begin
      writeln(f1, '--------------------------------------');
      writeln(f1, r, ' мутация');
      writeln(f1, 'вероятность мутации, выбранная случайным образом: ', kRandom:0:4);
    end;
    
    if (kRandom <= mutationProbability) then
    begin
      
      if mode = 1 then
      begin
        waq := RealXToBit(population[i]);
        wer := wordTo2(waq);
        writeln(f1, 'мутация произошла');
        writeln(f1, i + 1, ' особь до мутации:    ', wer);
      end;
      k := k + 1; //количество мутаций
      xi := RealXToBit(population[i]);
      lRandom := random(16);
      if mode = 1 then writeln(f1, 'бит, выбранный случайным образом: ', lRandom);
      xi := 1 shl lRandom xor xi; 
      population[i] := BitXToReal(xi);
      if mode = 1 then 
      begin
        waq := RealXToBit(population[i]);
        wer := wordTo2(waq);
        writeln(f1, i + 1, ' особь после мутации: ', wer);
      end;
    end
    else
    begin
      if mode = 1 then
      begin
        writeln(f1, 'мутация не произошла');
      end;
    end;
    if k >= mutationCount then break;
  end;
  if mode = 1 then
  begin
    writeln(f1, '                          |--------------------------------------|');
    writeln(f1, '                          |-------ОПЕРАЦИЯ МУТАЦИИ.КОНЕЦ.--------|');
    writeln(f1, '                          |--------------------------------------|');
    writeln(f1, ' ');
  end;
end;





{основной блок}
begin
  randomize; 
  iterCount := 0;
  porog := F(0.094);
  writeln('Введите режим работы программы(0 - основной; 1 - тестовый): '); 
  read(mode); 
  if mode = 1 then 
  begin
    assign(f1, 'debug.txt'); 
    rewrite(f1);
    writeln(f1, 'значение порога: ', F(0.14):0:10);
    writeln('Введите 1, если хотите распечатать на экран популяцию решений, получаемую на каждом шаге работы алгоритма, 0 - иначе: ');
    read(isPrintToScreen); 
  end;
  writeln('Введите количество скрещиваний: ');
  read(screschCount);
  if mode = 1 then writeln(f1, 'Количество скрещиваний: ', screschCount);
  writeln('Введите вероятность скрещивания: ');
  read(probobilityScresch);
  if mode = 1 then writeln(f1, 'Вероятность скрещивания: ', probobilityScresch);
  writeln('Введите количество мутаций в популяции: ');
  read(mutationCount);
  if mode = 1 then writeln(f1, 'Количество мутаций в популяции:  ', mutationCount);
  writeln('Введите вероятность мутации: ');
  read(mutationProbability);
  if mode = 1 then writeln(f1, 'Вероятность мутации: ', mutationProbability);
  population := createInitialPopulation(N);
  
  repeat
    iterCount := iterCount + 1;
    PrintIterationNumber(iterCount);
    if iterCount >= 2 then 
    begin
   	  //оператор селекции
      selection(population, screschCount);
   	  //оператор скрещивания 
      DoScresch(population, screschCount); 
      //оператор мутации 
      mutation(population); 
    end;
    
    PrintPopulation(population, iterCount);
    maxOsob := findMaxOsob(population);
    if iterCount = 1 then
    begin
      prevMax := maxOsob;
      prevF := F( prevMax);
      iterNumberWhenMax := 1;
    end
    else
    if F(maxOsob) > F(prevMax) then
    begin
      prevMax := maxOsob;
      prevF := F( prevMax);
      iterNumberWhenMax := iterCount;
    end;
    if mode = 1 then 
    begin
      writeln(f1, '|---------------------------------------------------------');
      writeln(f1, '|лучший результат = ', prevMax:0:6);
      writeln(f1, '|на какой итерации нашелся максимум из максимумов = ', iterNumberWhenMax);
      writeln(f1, '|значение лучшего результата = ', prevF:0:6); 
      writeln(f1, '|---------------------------------------------------------');
    end;
      
    if iterCount = 1000 then  
      break;
    
  until isStopByCriterion(maxOsob, porog, eps); 
  
  PrintResult(maxOsob, iterCount);
  if mode = 1 then
    close(f1);
  writeln('Выполнение программы завершено');
end.  