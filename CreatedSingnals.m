% WorkingTemperature [C]
% NumberOfSensors
% PacketTime [ms]
% NumberOfSlot
%Output Frequency [kHz]
% CrystalOscillatorParam
% 1. Frequency Tolerance [ppm]
% 2. Temperature Coefficient [ppm/C2]
% 3. Aging@+25 [ppm]

function [result,param] = CreatedSingnals(WorkingTemperature,NumberOfSensors,PacketTime,SlotToScan,OutputFrequency,CrystalOscillatorParam)
    
    MiliSecondsInOneYear = 1000*60*60*24*365;

     FreqBase = OutputFrequency*10^3;
     TimeBase = 1/FreqBase;
    
     NumbersOfSlots = SlotToScan(2) - SlotToScan(1) + 1;
     result = zeros(NumberOfSensors,2,NumbersOfSlots);
     
     if size(CrystalOscillatorParam,1) > 1
         FreqTol = CrystalOscillatorParam(:,1);
         DryftAging = CrystalOscillatorParam(:,2);
         TempCoef = CrystalOscillatorParam(:,3);
     else
         FreqTol = CrystalOscillatorParam(1)*(10^(-6))* (-1+ 2.*rand(NumberOfSensors,1));    % +/- 20 ppm
         DryftAging = CrystalOscillatorParam(2)*10^(-6)*(-1+ 2.*rand(NumberOfSensors,1)); % +/- 3 ppm
         TempCoef = CrystalOscillatorParam(3)*10^(-6)*(0.9 + 0.2.*rand(NumberOfSensors,1)); % -0.035 ppm/C2 +/- 10%
     end
     
     Freq = zeros(NumberOfSensors,4);
     StartTime = zeros(NumberOfSensors,4);
     
     Freq(:,1) = ones(NumberOfSensors,1)*FreqBase;
     Freq(:,2) = FreqBase + FreqTol*FreqBase;
     
     for CounterSlot = SlotToScan(1):SlotToScan(2)
        %Wygenerowanie czasu startu transmisji
            % 1. Staly offset
            WorkingTimeOffsetMiliSeconds = PacketTime*NumberOfSensors*(CounterSlot-1);
            StartTime(:,1) = linspace(WorkingTimeOffsetMiliSeconds,WorkingTimeOffsetMiliSeconds+((PacketTime)*(NumberOfSensors-1)),NumberOfSensors);

            % 2. Stały offset z uwzglednieniem tolerancji czestotliwosci produkcyjnej
            StartTime(:,2) = StartTime(:,1) + (Freq(:,1) - Freq(:,2)) * TimeBase .* StartTime(:,1);

            % 3. Stały offset z uwzglednieniem tolerancji
            % czestotliwosci produkcyjnej oraz dryftu starzeniowego
            Freq(:,3) = Freq(:,2) + StartTime(:,2)./MiliSecondsInOneYear.*DryftAging.*Freq(:,2);
            StartTime(:,3) = StartTime(:,2) + (Freq(:,2) - Freq(:,3)) * TimeBase .* StartTime(:,2);

            % 4. Stały offset (Guard time = FreqTol) z uwzglednieniem tolerancji
            % czestotliwosci produkcyjnej, dryftu starzeniowego oraz temperaturowego.
            Freq(:,4) = Freq(:,3) + TempCoef*(25-WorkingTemperature)^2.*Freq(:,3);
            StartTime(:,4) = StartTime(:,3) + (Freq(:,3) - Freq(:,4)) * TimeBase .* StartTime(:,3);


        %Wygenerowanie tablicy wektorów 2 elementowych z czasem startu oraz
        %stopu transmisji
            result(:,1,CounterSlot -  SlotToScan(1) + 1) = StartTime(:,4);
            result(:,2,CounterSlot -  SlotToScan(1) + 1) = StartTime(:,4) + PacketTime;
     end
        param = [FreqTol,DryftAging,TempCoef,Freq(:,4)];
end