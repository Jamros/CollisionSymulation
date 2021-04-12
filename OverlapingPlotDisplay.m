function OverlapingPlotDisplay(NumberOfSensors,PacketTime,SlotToScan,OverlapingMatrix,OverlapingMatrixFull,MovingAverangeStop,StartStopVector,PlotingNumbers)
    LeftCollisionDim = 1;
    RightCollisionDim = 2;
     
    NumberOfOverLapingInAll = 0;
    
    if size(size(OverlapingMatrixFull),2) >= 3
        if size(OverlapingMatrix,1) < 1
            OverlapingMatrix = zeros(NumberOfSensors,SlotToScan(2),2);
            OverlapingMatrix(:,:,1) = OverlapingMatrixFull(:,:,LeftCollisionDim) + OverlapingMatrixFull(:,:,RightCollisionDim);
            OverlapingMatrix(:,:,2) = OverlapingMatrixFull(:,:,3) + OverlapingMatrixFull(:,:,4);
            OverlapingMatrix(find(OverlapingMatrix(:,:,2)>PacketTime)+NumberOfSensors*SlotToScan(2)) = PacketTime;
        end
%         if and(PlotingNumbers(8)==0,PlotingNumbers(2)==0)
%             clearvars OverlapingMatrixFull
%         end
    else
        OverlapingMatrix = OverlapingMatrixFull;
%         if and(PlotingNumbers(8)==0,PlotingNumbers(2)==0)
%             clearvars OverlapingMatrixFull
%         end
    end
    
%     if size(OverlapingMatrixFull,1) == size(OverlapingMatrixFull,2)
%         NumberOfOverLapingInSlots = sum(sum(OverlapingMatrix(:,:,:,1)>0)>0);
%         NumberOfOverLapingInSlots = reshape(NumberOfOverLapingInSlots,size(NumberOfOverLapingInSlots,3),1);
%         
%     else
        if PlotingNumbers(5)
            NumberOfOverLapingInAll = sum(OverlapingMatrix(:,:,1).'>0);
        end
        if PlotingNumbers(4)
            MeanTimeOfOverlapingInSlots = mean(OverlapingMatrix(:,:,2));
        end
        if or(PlotingNumbers(6)>0,PlotingNumbers(3)>0)
            TimeOfOverlapingInSlots = OverlapingMatrix(:,:,2);
        end
        if or(PlotingNumbers(1)>0,PlotingNumbers(2)>0)
            NumberOfOverLapingInSlots = sum(OverlapingMatrix(:,:,1)>0);
            NumberOfOverLapingInSlots = reshape(NumberOfOverLapingInSlots(:,:,1),size(NumberOfOverLapingInSlots,2),1);
        end 
%     end

    ObservationSlots = SlotToScan(2) -SlotToScan(1)+1;
    MiliSecondInDay = (1000 * 60 * 60 * 24);
    StepTime = PacketTime*NumberOfSensors / MiliSecondInDay;
    StopTime = StepTime * (ObservationSlots - 1);
    
    ObservationSlots = SlotToScan(2) -SlotToScan(1)+1;
    MilisecondInMinutes = 1000*60;
    StepTime = PacketTime*NumberOfSensors / MilisecondInMinutes;
    StopTime = StepTime * (ObservationSlots - 1);
    
    %% Podać średnią, odchyelnie standardowe oraz obliczyć błąd średniokwadraturowy dla aproksymacji
    if PlotingNumbers(1)
        figure(1);
        hold on;
        DaysTime = 0:StepTime:StopTime;
        plot(DaysTime,NumberOfOverLapingInSlots,'-b');

        if MovingAverangeStop(1) > 0
             TmpNumberOfOverLapingInSlots = conv(NumberOfOverLapingInSlots, ones(1,MovingAverangeStop(1)), 'valid');
             TmpNumberOfOverLapingInSlots = TmpNumberOfOverLapingInSlots / MovingAverangeStop(1);
             TimeTmp = DaysTime(1:end-MovingAverangeStop(1)+1);
             plot(TimeTmp,TmpNumberOfOverLapingInSlots.','-r','LineWidth',2);
        end
        
        hold off;
        title("Ilość zakłóconych transmisji w funkcji czasu",'Fontsize',14,'FontName','Times New Roman')
        ylabel("Ilość transmisji [AU] ",'Fontsize',14,'FontName','Times New Roman');
        xlabel("Czas [dni]",'Fontsize',14,'FontName','Times New Roman');
        grid on;
        
        clearvars TimeTmp DaysTime
    end
    
    if PlotingNumbers(2)
        figure(2);
        
        NumberOfOverLapingInSlotsLeft = sum(OverlapingMatrixFull(:,:,LeftCollisionDim)>0);
        NumberOfOverLapingInSlotsLeft = reshape(NumberOfOverLapingInSlotsLeft(:,:,1),size(NumberOfOverLapingInSlotsLeft,2),1);
%         NumberOfOverLapingInSlotsRight = sum(OverlapingMatrixFull(:,:,RightCollisionDim)>0);
%         NumberOfOverLapingInSlotsRight = reshape(NumberOfOverLapingInSlotsRight(:,:,1),size(NumberOfOverLapingInSlotsRight,2),1);
        
         clearvars OverlapingMatrixFull
         
         NumberOfOverLapingInSlotsLeft90DayTo180Day = NumberOfOverLapingInSlotsLeft(70692:end);
         NumberOfOverLapingInSlotsLeft180DayTo365Day = NumberOfOverLapingInSlotsLeft(141382:end);
         NumberOfOverLapingInSlotsLeft1YearTo2Year = NumberOfOverLapingInSlotsLeft(286691:end);
         NumberOfOverLapingInSlotsLeft2YearTo3Year = NumberOfOverLapingInSlotsLeft(573382:end);

        
        subplot(221);
        hold on;
        hist = histogram(NumberOfOverLapingInSlotsLeft2YearTo3Year,'Normalization','probability'); %From 53 to 69 neared to gauss
        title(["Rozkład prawdopodobieństwa ilości zakłóceń ";"w stosunku do jednego slotu czasowego" ; "od 2 lat do 9 lat"],'Fontsize',14,'FontName','Times New Roman')
        ylabel(["Prawdopodobieństwo";"wystąpienia zdarzenia"],'Fontsize',14,'FontName','Times New Roman');
        xlabel(["Ilość zakłóceń [AU]";"a)"],'Fontsize',14,'FontName','Times New Roman');
        
        x = hist.BinLimits(1):0.1:hist.BinLimits(2); 
        pdNormal = fitdist(NumberOfOverLapingInSlotsLeft2YearTo3Year.','Normal')
        yNormal = pdf(pdNormal,x);
        plot(x,yNormal,'LineWidth',1.5);
        legend(["Rozkład zakłóceń";"Rozkład normalny"])
        hold off;
        grid on;
        
        x = hist.BinLimits(1)+0.5:1:hist.BinLimits(2)-0.5; 
        yNormal = pdf(pdNormal,x);
        HistValues = hist.Values;
        Error = immse(yNormal,HistValues);
        disp(Error);

        subplot(222);
        hold on;
        hist = histogram(NumberOfOverLapingInSlotsLeft90DayTo180Day,[15:67],'Normalization','probability');
        title(["Rozkład prawdopodobieństwa ilości zakłóceń ";"w stosunku do jednego slotu czasowego" ; "od 90 dni do 9 lat"],'Fontsize',14,'FontName','Times New Roman')
        ylabel(["Prawdopodobieństwo";"wystąpienia zdarzenia"],'Fontsize',14,'FontName','Times New Roman');
        xlabel(["Ilość zakłóceń [AU]";"c)"],'Fontsize',14,'FontName','Times New Roman');
        x = hist.BinLimits(1):0.1:hist.BinLimits(2); 
        pdNormal = fitdist(NumberOfOverLapingInSlotsLeft90DayTo180Day.','Normal')
        yNormal = pdf(pdNormal,x);
        plot(x,yNormal,'LineWidth',1.5);
        legend(["Rozkład zakłóceń";"Rozkład normalny"])
        hold off;
        grid on;
        
        x = hist.BinLimits(1)+0.5:1:hist.BinLimits(2)-0.5; 
        yNormal = pdf(pdNormal,x);
        HistValues = hist.Values;
        Error = immse(yNormal,HistValues);
        disp(Error);
        
        subplot(223);
        hold on;
        hist = histogram(NumberOfOverLapingInSlotsLeft180DayTo365Day,'Normalization','probability');
        title(["Rozkład prawdopodobieństwa ilości zakłóceń ";"w stosunku do jednego slotu czasowego" ; "od 180 dni do 9 lat"],'Fontsize',14,'FontName','Times New Roman')
        ylabel(["Prawdopodobieństwo";"wystąpienia zdarzenia"],'Fontsize',14,'FontName','Times New Roman');
        xlabel(["Ilość zakłóceń [AU]";"b)"],'Fontsize',14,'FontName','Times New Roman');
        x = hist.BinLimits(1):0.1:hist.BinLimits(2); 
        pdNormal = fitdist(NumberOfOverLapingInSlotsLeft180DayTo365Day.','Normal')
        yNormal = pdf(pdNormal,x);
        plot(x,yNormal,'LineWidth',1.5);
        legend(["Rozkład zakłóceń";"Rozkład normalny"])
        hold off;
        grid on;
        
        x = hist.BinLimits(1)+0.5:1:hist.BinLimits(2)-0.5; 
        yNormal = pdf(pdNormal,x);
        HistValues = hist.Values;
        Error = immse(yNormal,HistValues);
        disp(Error);
        
        subplot(224);
        hold on;
        hist = histogram(NumberOfOverLapingInSlotsLeft1YearTo2Year,'Normalization','probability');
        title(["Rozkład prawdopodobieństwa ilości zakłóceń ";"w stosunku do jednego slotu czasowego" ; "od 1 roku do 9 lat"],'Fontsize',14,'FontName','Times New Roman')
        ylabel(["Prawdopodobieństwo";"wystąpienia zdarzenia"],'Fontsize',14,'FontName','Times New Roman');
        xlabel(["Ilość zakłóceń [AU]";"d)"],'Fontsize',14,'FontName','Times New Roman');
        
        x = hist.BinLimits(1):0.1:hist.BinLimits(2); 
        pdNormal = fitdist(NumberOfOverLapingInSlotsLeft1YearTo2Year.','Normal');
        yNormal = pdf(pdNormal,x);
        plot(x,yNormal,'LineWidth',1.5);
        legend(["Rozkład zakłóceń";"Rozkład normalny"])
        hold off;
        grid on;
        
        x = hist.BinLimits(1)+0.5:1:hist.BinLimits(2)-0.5; 
        yNormal = pdf(pdNormal,x);
        HistValues = hist.Values;
        Error = immse(yNormal,HistValues);
        disp(Error);
    end
    
    if PlotingNumbers(3)
        figure(3);
        
        clearvars OverlapingMatrixFull
        
        subplot(425);
        histogram(TimeOfOverlapingInSlots(TimeOfOverlapingInSlots > 0 & TimeOfOverlapingInSlots < PacketTime).','Normalization','probability');
        xlabel(["Czas trwania zakłócenia [ms]";"c)"],'Fontsize',14,'FontName','Times New Roman');
        ylabel(["Prawdopodobieństwo" ; "wystąpienia zdarzenia"],'Fontsize',14,'FontName','Times New Roman');
        grid on;
        
        
        subplot(421);
        X = categorical({'Brak','Częściowe','Całkowite'});
        X = reordercats(X,{'Brak','Częściowe','Całkowite'});
        Y(1) = sum(sum(TimeOfOverlapingInSlots==0,2))/(size(TimeOfOverlapingInSlots,1)*size(TimeOfOverlapingInSlots,2));
        Y(3) = sum(sum(TimeOfOverlapingInSlots==PacketTime,2))/(size(TimeOfOverlapingInSlots,1)*size(TimeOfOverlapingInSlots,2));
        Y(2) = 1 - Y(1) - Y(3);
        b = bar(X,Y);

        %title("Rozkład prawdopodobieństwa czasu trawania zakłócenia",'Fontsize',14,'FontName','Times New Roman')
        xlabel(["Stopień zakłócenia wiadomości";"a)"],'Fontsize',14,'FontName','Times New Roman');
        ylabel(["Prawdopodobieństwo ";"wystąpienia zdarzenia"],'Fontsize',14,'FontName','Times New Roman');
        grid on;

        xtips1 = b(1).XEndPoints;
        ytips1 = b(1).YEndPoints;
        labels1 = string(round(b(1).YData,3));
        text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    
        subplot(423);
        X = categorical({'Brak','Częściowe','Całkowite'});
        X = reordercats(X,{'Brak','Częściowe','Całkowite'});

        TimeOfOverlapingInSlotsFirstHour = TimeOfOverlapingInSlots(:,1:33);
        TimeOfOverlapingInSlotsFirstHourToFirstDay = TimeOfOverlapingInSlots(:,34:786);
        TimeOfOverlapingInSlotsFirstDayTo10Day = TimeOfOverlapingInSlots(:,787:7855);
        TimeOfOverlapingInSlotsFirst10DayTo30Day = TimeOfOverlapingInSlots(:,7855:7855+7855);
        TimeOfOverlapingInSlotsFirst30DayTo60Day = TimeOfOverlapingInSlots(:,23564:23564+7855);
        TimeOfOverlapingInSlotsFirst60DayTo90Day = TimeOfOverlapingInSlots(:,47128:47128+7855);
        TimeOfOverlapingInSlotsFirst90DayTo180Day = TimeOfOverlapingInSlots(:,70692:70692+7855);
        TimeOfOverlapingInSlotsFirst180DayTo365Day = TimeOfOverlapingInSlots(:,141382:141382+7855);
        TimeOfOverlapingInSlotsFirst1YearTo2Year = TimeOfOverlapingInSlots(:,286691:286691+7855);
        TimeOfOverlapingInSlotsFirst2YearTo4Year = TimeOfOverlapingInSlots(:,573382:573382+7855);
        TimeOfOverlapingInSlotsFirst4YearTo9Year = TimeOfOverlapingInSlots(:,1146764:1146764+7855);

        Y(1,1) = sum(sum(TimeOfOverlapingInSlotsFirstHour==0,2))/(size(TimeOfOverlapingInSlotsFirstHour,1)*size(TimeOfOverlapingInSlotsFirstHour,2));
        Y(3,1) = sum(sum(TimeOfOverlapingInSlotsFirstHour==PacketTime,2))/(size(TimeOfOverlapingInSlotsFirstHour,1)*size(TimeOfOverlapingInSlotsFirstHour,2));
        Y(1,2) = sum(sum(TimeOfOverlapingInSlotsFirstHourToFirstDay==0,2))/(size(TimeOfOverlapingInSlotsFirstHourToFirstDay,1)*size(TimeOfOverlapingInSlotsFirstHourToFirstDay,2));
        Y(3,2) = sum(sum(TimeOfOverlapingInSlotsFirstHourToFirstDay==PacketTime,2))/(size(TimeOfOverlapingInSlotsFirstHourToFirstDay,1)*size(TimeOfOverlapingInSlotsFirstHourToFirstDay,2));
        Y(1,3) = sum(sum(TimeOfOverlapingInSlotsFirstDayTo10Day==0,2))/(size(TimeOfOverlapingInSlotsFirstDayTo10Day,1)*size(TimeOfOverlapingInSlotsFirstDayTo10Day,2));
        Y(3,3) = sum(sum(TimeOfOverlapingInSlotsFirstDayTo10Day==PacketTime,2))/(size(TimeOfOverlapingInSlotsFirstDayTo10Day,1)*size(TimeOfOverlapingInSlotsFirstDayTo10Day,2));
        Y(1,4) = sum(sum(TimeOfOverlapingInSlotsFirst10DayTo30Day==0,2))/(size(TimeOfOverlapingInSlotsFirst10DayTo30Day,1)*size(TimeOfOverlapingInSlotsFirst10DayTo30Day,2));
        Y(3,4) = sum(sum(TimeOfOverlapingInSlotsFirst10DayTo30Day==PacketTime,2))/(size(TimeOfOverlapingInSlotsFirst10DayTo30Day,1)*size(TimeOfOverlapingInSlotsFirst10DayTo30Day,2));
        Y(1,5) = sum(sum(TimeOfOverlapingInSlotsFirst30DayTo60Day==0,2))/(size(TimeOfOverlapingInSlotsFirst30DayTo60Day,1)*size(TimeOfOverlapingInSlotsFirst30DayTo60Day,2));
        Y(3,5) = sum(sum(TimeOfOverlapingInSlotsFirst30DayTo60Day==PacketTime,2))/(size(TimeOfOverlapingInSlotsFirst30DayTo60Day,1)*size(TimeOfOverlapingInSlotsFirst30DayTo60Day,2));
        Y(1,6) = sum(sum(TimeOfOverlapingInSlotsFirst60DayTo90Day==0,2))/(size(TimeOfOverlapingInSlotsFirst60DayTo90Day,1)*size(TimeOfOverlapingInSlotsFirst60DayTo90Day,2));
        Y(3,6) = sum(sum(TimeOfOverlapingInSlotsFirst60DayTo90Day==PacketTime,2))/(size(TimeOfOverlapingInSlotsFirst60DayTo90Day,1)*size(TimeOfOverlapingInSlotsFirst60DayTo90Day,2));
        Y(1,7) = sum(sum(TimeOfOverlapingInSlotsFirst90DayTo180Day==0,2))/(size(TimeOfOverlapingInSlotsFirst90DayTo180Day,1)*size(TimeOfOverlapingInSlotsFirst90DayTo180Day,2));
        Y(3,7) = sum(sum(TimeOfOverlapingInSlotsFirst90DayTo180Day==PacketTime,2))/(size(TimeOfOverlapingInSlotsFirst90DayTo180Day,1)*size(TimeOfOverlapingInSlotsFirst90DayTo180Day,2));
        Y(1,8) = sum(sum(TimeOfOverlapingInSlotsFirst180DayTo365Day==0,2))/(size(TimeOfOverlapingInSlotsFirst180DayTo365Day,1)*size(TimeOfOverlapingInSlotsFirst180DayTo365Day,2));
        Y(3,8) = sum(sum(TimeOfOverlapingInSlotsFirst180DayTo365Day==PacketTime,2))/(size(TimeOfOverlapingInSlotsFirst180DayTo365Day,1)*size(TimeOfOverlapingInSlotsFirst180DayTo365Day,2));
        Y(1,9) = sum(sum(TimeOfOverlapingInSlotsFirst1YearTo2Year==0,2))/(size(TimeOfOverlapingInSlotsFirst1YearTo2Year,1)*size(TimeOfOverlapingInSlotsFirst1YearTo2Year,2));
        Y(3,9) = sum(sum(TimeOfOverlapingInSlotsFirst1YearTo2Year==PacketTime,2))/(size(TimeOfOverlapingInSlotsFirst1YearTo2Year,1)*size(TimeOfOverlapingInSlotsFirst1YearTo2Year,2));
        Y(1,10) = sum(sum(TimeOfOverlapingInSlotsFirst2YearTo4Year==0,2))/(size(TimeOfOverlapingInSlotsFirst2YearTo4Year,1)*size(TimeOfOverlapingInSlotsFirst2YearTo4Year,2));
        Y(3,10) = sum(sum(TimeOfOverlapingInSlotsFirst2YearTo4Year==PacketTime,2))/(size(TimeOfOverlapingInSlotsFirst2YearTo4Year,1)*size(TimeOfOverlapingInSlotsFirst2YearTo4Year,2));
        Y(1,11) = sum(sum(TimeOfOverlapingInSlotsFirst4YearTo9Year==0,2))/(size(TimeOfOverlapingInSlotsFirst4YearTo9Year,1)*size(TimeOfOverlapingInSlotsFirst4YearTo9Year,2));
        Y(3,11) = sum(sum(TimeOfOverlapingInSlotsFirst4YearTo9Year==PacketTime,2))/(size(TimeOfOverlapingInSlotsFirst4YearTo9Year,1)*size(TimeOfOverlapingInSlotsFirst4YearTo9Year,2));
        Y(2,:) = 1 - Y(1,:) - Y(3,:);
        bar(X,Y);
        clearvars  X Y
        
        title(["Rozkład prawdopodobieństwa stopnia zakłócenia";"wiadomosci dla określonych przedziałów czasowych"],'Fontsize',14,'FontName','Times New Roman')
        xlabel("Stopień zakłócenia wiadomości",'Fontsize',14,'FontName','Times New Roman');
        ylabel(["Prawdopodobieństwo";"wystąpienia zdarzenia"],'Fontsize',14,'FontName','Times New Roman');
        legend(["Pierwsza godzina";"1 godzina - 1 doba";"1 doba - 10 dni";"10 dni - 20 dni";"30 dni - 40dni";"60 dni - 70 dni";"90 dni - 100dni";"180 dni - 190 dni";"365 dni - 375 dni";"Drugi rok - Drugi rok + 10 dni";"Czwarty rok - Czwarty rok + 10 dni"],'Fontsize',10,'FontName','Times New Roman','Location','northeast')
        grid on;
    

        subplot(422);
        histogram(TimeOfOverlapingInSlotsFirstHour(TimeOfOverlapingInSlotsFirstHour > 0 & TimeOfOverlapingInSlotsFirstHour < PacketTime).','Normalization','probability');
        title(["Rozkład prawdopodobieństwa czasu trawania zakłócenia dla różnych przedziałów czasowych";""],'Fontsize',14,'FontName','Times New Roman')
        xlabel(["Czas trwania zakłócenia [ms]";"a)"],'Fontsize',14,'FontName','Times New Roman');
        ylabel(["Prawdopodobieństwo" ; "wystąpienia zdarzenia"],'Fontsize',14,'FontName','Times New Roman');
        legend("Pierwsza godzina",'Fontsize',10,'FontName','Times New Roman','Location','north')
        grid on;

        subplot(424);
        hold on;
        hist = histogram(TimeOfOverlapingInSlotsFirstHourToFirstDay(TimeOfOverlapingInSlotsFirstHourToFirstDay > 0 & TimeOfOverlapingInSlotsFirstHourToFirstDay < PacketTime).','Normalization','probability');
        BinEdges = hist.BinEdges;
        histogram(TimeOfOverlapingInSlotsFirstDayTo10Day(TimeOfOverlapingInSlotsFirstDayTo10Day > 0 & TimeOfOverlapingInSlotsFirstDayTo10Day < PacketTime).',BinEdges,'Normalization','probability');
        xlabel(["Czas trwania zakłócenia [ms]";"c)"],'Fontsize',14,'FontName','Times New Roman');
        ylabel(["Prawdopodobieństwo" ; "wystąpienia zdarzenia"],'Fontsize',14,'FontName','Times New Roman');
        legend(["Pierwsza godzina - Dzień 1";"Dzień 1 - Dzień 10"],'Fontsize',10,'FontName','Times New Roman','Location','north')
        grid on;
        
        subplot(426);
        hold on;
        histogram(TimeOfOverlapingInSlotsFirst10DayTo30Day(TimeOfOverlapingInSlotsFirst10DayTo30Day > 0 & TimeOfOverlapingInSlotsFirst10DayTo30Day < PacketTime).',BinEdges,'Normalization','probability');
        histogram(TimeOfOverlapingInSlotsFirst30DayTo60Day(TimeOfOverlapingInSlotsFirst30DayTo60Day > 0 & TimeOfOverlapingInSlotsFirst30DayTo60Day < PacketTime).',BinEdges,'Normalization','probability');
        histogram(TimeOfOverlapingInSlotsFirst90DayTo180Day(TimeOfOverlapingInSlotsFirst90DayTo180Day > 0 & TimeOfOverlapingInSlotsFirst90DayTo180Day < PacketTime).',BinEdges,'Normalization','probability');
        histogram(TimeOfOverlapingInSlotsFirst180DayTo365Day(TimeOfOverlapingInSlotsFirst180DayTo365Day > 0 & TimeOfOverlapingInSlotsFirst180DayTo365Day < PacketTime).',BinEdges,'Normalization','probability');
        hold off;

        xlabel(["Czas trwania zakłócenia [ms]";"d)"],'Fontsize',14,'FontName','Times New Roman');
        ylabel(["Prawdopodobieństwo" ; "wystąpienia zdarzenia"],'Fontsize',14,'FontName','Times New Roman');
        legend(["Dzień 10 - Dzień 20";"Dzień 30 - Dzień 40";"Dzień 90 - Dzień 100";"Dzień 180 - Dzień 190";],'Fontsize',10,'FontName','Times New Roman','Location','northwest')
        grid on;
        
        subplot(428);
        hold on;
        histogram(TimeOfOverlapingInSlotsFirst180DayTo365Day(TimeOfOverlapingInSlotsFirst180DayTo365Day > 0 & TimeOfOverlapingInSlotsFirst180DayTo365Day < PacketTime).',BinEdges,'Normalization','probability');
        histogram(TimeOfOverlapingInSlotsFirst1YearTo2Year(TimeOfOverlapingInSlotsFirst1YearTo2Year > 0 & TimeOfOverlapingInSlotsFirst1YearTo2Year < PacketTime).',BinEdges,'Normalization','probability');
        histogram(TimeOfOverlapingInSlotsFirst2YearTo4Year(TimeOfOverlapingInSlotsFirst2YearTo4Year > 0 & TimeOfOverlapingInSlotsFirst2YearTo4Year < PacketTime).',BinEdges,'Normalization','probability');
        histogram(TimeOfOverlapingInSlotsFirst4YearTo9Year(TimeOfOverlapingInSlotsFirst4YearTo9Year > 0 & TimeOfOverlapingInSlotsFirst4YearTo9Year < PacketTime).',BinEdges,'Normalization','probability');
        hold off;

        xlabel(["Czas trwania zakłócenia [ms]";"d)"],'Fontsize',14,'FontName','Times New Roman');
        ylabel(["Prawdopodobieństwo" ; "wystąpienia zdarzenia"],'Fontsize',14,'FontName','Times New Roman');
        legend(["Dzień 180 - Dzień 190";"Dzień 365 - Dzień 375";"Drugi rok - Drugi rok + 10 dni";"Czwarty rok - Czwarty rok + 10 dni"],'Fontsize',10,'FontName','Times New Roman','Location','northwest')
        grid on;
        
        clearvars  X Y
        clearvars TimeOfOverlapingInSlotsFirstHour
        clearvars TimeOfOverlapingInSlotsFirstHourToFirstDay
        clearvars TimeOfOverlapingInSlotsFirstDayTo10Day
        clearvars TimeOfOverlapingInSlotsFirst10DayTo30Day
        clearvars TimeOfOverlapingInSlotsFirst30DayTo60Day
        clearvars TimeOfOverlapingInSlotsFirst60DayTo90Day
        clearvars TimeOfOverlapingInSlotsFirst90DayTo180Day
        clearvars TimeOfOverlapingInSlotsFirst180DayTo365Day
        clearvars TimeOfOverlapingInSlotsFirst1YearTo2Year
        clearvars TimeOfOverlapingInSlotsFirst2YearTo4Year
        clearvars TimeOfOverlapingInSlotsFirst4YearTo9Year

    end
    
    if PlotingNumbers(4)
        figure(4);
        hold on;
        DaysTime = 0:StepTime:StopTime;
        plot(DaysTime,MeanTimeOfOverlapingInSlots,'-b');
            
        if MovingAverangeStop(2) > 0
             TmpMeanTimeOfOverlapingInSlots = conv(MeanTimeOfOverlapingInSlots, ones(1,MovingAverangeStop(2)), 'valid');
             TmpMeanTimeOfOverlapingInSlots = TmpMeanTimeOfOverlapingInSlots / MovingAverangeStop(2);
             TimeTmp = DaysTime(1:end-MovingAverangeStop(2)+1);
             plot(TimeTmp,TmpMeanTimeOfOverlapingInSlots,'-r','LineWidth',2);
        end

        hold off;
        title(["Średni czasu trawania zakłócenia w funkcji czasu"])
        xlabel("Czas [dni]");
        ylabel("Średnia [ms]");
        grid on;
        
        clearvars TimeTmp DaysTime
    end
    
    if PlotingNumbers(5)
        figure(5);
        hold on;
        bar(NumberOfOverLapingInAll/ObservationSlots);
        hold off;
        title(["Prawdopodobieństwo wystąpienia kolizji ";"dla poszczególnych urządzeń końcowych"])
        xlabel("Numer urządzenia końcowego [AU] ");
        ylabel("Prawdopodobieństwo zakłócenia transmisji");
        grid on;
    end

    if PlotingNumbers(6)
        figure(6);
        hold on;
        bar(1:1:NumberOfSensors,mean(TimeOfOverlapingInSlots,2));
        hold off;
        title(["Średni czas zakłócenia transmisji ";"dla poszczególnego urządzenia końcowego"])
        xlabel("Numer urządzenia końcowego [AU] ");
        ylabel("Średni czas zakłócenia transmisji [ms]");
        grid on;
    end
    
    if PlotingNumbers(7)
      figure(7)
      %MilisecondIn30Day = MiliSecondInDay*30;
      MilisecondIn365Day = MiliSecondInDay*365;
      %MessageSendCount = MilisecondIn30Day / (PacketTime * NumberOfSensors);
      MessageSendCount = MilisecondIn365Day / (PacketTime * NumberOfSensors);
      DeltaMessage = (StartStopVector(:,1,end)/ (PacketTime * NumberOfSensors)) - MessageSendCount;
      bar(ceil(DeltaMessage));
      title(["Różnica w ilości wysłanych komunikatów dla ";"każdego urządzenia końcowego po 365 dniach"])
      xlabel("Numer urządzenia końcowego [AU]");
      ylabel("\Delta Ilość wiadomości [AU]");
      grid on;
    end
    
    if PlotingNumbers(8)
      figure(8);
      
      MeanCounterCollsionInDevices = mean(OverlapingMatrix(:,:,1),2);
      
      subplot(211);
      [~, MinI] = mink(MeanCounterCollsionInDevices,3);
      [~, MaxI] = maxk(MeanCounterCollsionInDevices,3);
      b = bar(MeanCounterCollsionInDevices);
      b.FaceColor = 'flat';
      b.CData([MinI MaxI],:) = [1 0 0;1 0 0;1 0 0;0 1 1;0 1 1;0 1 1];
      title("Średnia ilośc zakłóceń dla poszczególnego urządzenia końcowego",'Fontsize',14,'FontName','Times New Roman')
      xlabel("Numer urządzenia końcowego [AU]",'Fontsize',14,'FontName','Times New Roman');
      ylabel("Średnia ilości zakłóceń [ms]",'Fontsize',14,'FontName','Times New Roman');
      grid on;
      
        xtips1 = b(1).XEndPoints;
        ytips1 = b(1).YEndPoints;
        labels1 = string(round(b(1).YData,2));
        text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
      
     StdCounterCollsionInDevices = Std(OverlapingMatrix(:,:,1),0,2);
      [~, StdMaxI] = maxk(StdCounterCollsionInDevices,3);
      
      subplot(212);
      b = bar(StdCounterCollsionInDevices);
      b.FaceColor = 'flat';
      b.CData([MinI;MaxI],:) = [1 0 0;1 0 0;1 0 0;0 1 1;0 1 1;0 1 1];
      b.CData(StdMaxI,:) = [.2 .2 .2;.2 .2 .2;.2 .2 .2];
      title(["Odchylenie standardowe ilośc zakłóceń";" dla poszczególnego urządzenia końcowego"],'Fontsize',14,'FontName','Times New Roman')
      xlabel("Numer urządzenia końcowego [AU]",'Fontsize',14,'FontName','Times New Roman');
      ylabel(["Odchylenie standardowe ";"ilości zakłóceń [ms]"],'Fontsize',14,'FontName','Times New Roman');
      grid on;
      
        xtips1 = b(1).XEndPoints;
        ytips1 = b(1).YEndPoints;
        labels1 = string(round(b(1).YData,2));
        text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
    
    
      subplot(313);
      MeanCounterCollsionInDevices = mean(OverlapingMatrix(:,:,1),2);
      histogram(MeanCounterCollsionInDevices);
      title("Rozkład średniej ilości kolizji dla jednego urządzenia",'Fontsize',14,'FontName','Times New Roman')
      xlabel("Średnia [ms]",'Fontsize',14,'FontName','Times New Roman');
      ylabel("Częstość [AU]",'Fontsize',14,'FontName','Times New Roman');
      grid on;
      
      
      
      
%       subplot(412);
%       
%       StdCounterCollsionInDevices = sqrt(std(OverlapingMatrix(:,:,1),0,2));
%       bar(StdCounterCollsionInDevices);
% 
%       title(["Wariancja ilośc zakłóceń dla poszczególnego urządzenia końcowego ";"z uwzględnieniem typu kolizji"])
%       xlabel(["Numer urządzenia końcowego [AU]";"b)";""]);
%       ylabel("Wariancja ilości zakłóceń");
%       grid on;
      
%       subplot(413);
%       MeanCounterCollsionInDevicesLeft = mean(OverlapingMatrixFull(:,:,LeftCollisionDim),2);
%       MeanCounterCollsionInDevicesRight = mean(OverlapingMatrixFull(:,:,RightCollisionDim),2);
% 
%       bar([MeanCounterCollsionInDevicesLeft MeanCounterCollsionInDevicesRight]);
% 
%       title(["Średnia ilośc zakłóceń dla poszczególnego urządzenia końcowego ";"z uwzględnieniem typu kolizji"])
%       xlabel(["Numer urządzenia końcowego [AU]";"a)";""]);
%       ylabel("Średnia ilości zakłóceń");
%       legend(["Zakłócenia lewostronne";"Zakłócenia prawostronne"])
%       grid on;
%       
%       subplot(414);
%       StdCounterCollsionInDevicesLeft = sqrt(std(OverlapingMatrixFull(:,:,LeftCollisionDim),0,2));
%       StdCounterCollsionInDevicesRight = sqrt(std(OverlapingMatrixFull(:,:,RightCollisionDim),0,2));
% 
%       bar([StdCounterCollsionInDevicesLeft StdCounterCollsionInDevicesRight]);
% 
%       title(["Wariancja ilości zakłóceń dla poszczególnego urządzenia końcowego ";"z uwzględnieniem typu kolizji"])
%       xlabel(["Numer urządzenia końcowego [AU]";"b)";""]);
%       ylabel("Wariancja ilości zakłóceń");
%       legend(["Zakłócenia lewostronne";"Zakłócenia prawostronne"])
%       grid on;
      
    end
end
%OverlapingPlotDisplay(25,PacketTime,[1 2239309],SimpleOverLapMonth(:,1:2239309,:),[32768 32768],1,ones(6,1));