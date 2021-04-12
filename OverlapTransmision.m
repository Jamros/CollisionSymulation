%% Signals: Array[Start,Stop]
function Result = OverlapTransmision(signals,PacketTime)
     CounterCollisionDim = 1;
     LeftCollisionTimeDim = 2;
     RightCollisonTimeDim = 3;
    
    DimensionsSignals = size(signals,1);
    NumberOfSlots = size(signals,3);
    tmpResult = zeros(DimensionsSignals,DimensionsSignals,NumberOfSlots,3);
    Result = zeros(DimensionsSignals,DimensionsSignals,NumberOfSlots,2);
    
    for TX1 = 1:DimensionsSignals
        disp(TX1);
        for TX2 = 1:TX1
            Start_TX1 = signals(TX1,1,1);
            Start_TX2 = signals(TX2,1,1);
            Stop_TX1 = signals(TX1,2,1);
            Stop_TX2 = signals(TX2,2,1); 
            if Start_TX2 < Stop_TX1 && Stop_TX2 > Start_TX1 && TX1 ~= TX2
                tmpResult(TX1,TX2,1,CounterCollisionDim)= tmpResult(TX1,TX2,1,CounterCollisionDim) + 1 ;
                tmpResult(TX2,TX1,1,CounterCollisionDim)= tmpResult(TX2,TX1,1,CounterCollisionDim) + 1 ;
                if Stop_TX1 > Stop_TX2
                    CollisionTime = Stop_TX2 - Start_TX1;
                    if CollisionTime > tmpResult(TX1,TX2,1,LeftCollisionTimeDim)
                        tmpResult(TX1,TX2,1,LeftCollisionTimeDim)= CollisionTime;
                    end
                    if CollisionTime > tmpResult(TX2,TX1,1,RightCollisonTimeDim)
                        tmpResult(TX2,TX1,1,RightCollisonTimeDim)= CollisionTime;
                    end
                else
                    CollisionTime = Stop_TX1 - Start_TX2;
                    if CollisionTime > tmpResult(TX1,TX2,1,RightCollisonTimeDim)
                        tmpResult(TX1,TX2,1,RightCollisonTimeDim)= CollisionTime;
                    end
                    if CollisionTime > tmpResult(TX2,TX1,1,LeftCollisionTimeDim)
                        tmpResult(TX2,TX1,1,LeftCollisionTimeDim)= CollisionTime;
                    end
                end 
            end
            
            for Slot_x = 2:NumberOfSlots     
                
                Start_TX2 = signals(TX2,1,Slot_x);
                Stop_TX2 = signals(TX2,2,Slot_x);
                Start_TX1 = signals(TX1,1,Slot_x);
                Stop_TX1 = signals(TX1,2,Slot_x);

                if Start_TX2 < Stop_TX1 && Stop_TX2 > Start_TX1 && TX1 ~= TX2
                    tmpResult(TX1,TX2,Slot_x,CounterCollisionDim)= tmpResult(TX1,TX2,Slot_x,CounterCollisionDim) + 1; %Slot_x ;
                    tmpResult(TX2,TX1,Slot_x,CounterCollisionDim)= tmpResult(TX2,TX1,Slot_x,CounterCollisionDim) + 1; %Slot_x ;
                    if Stop_TX1 > Stop_TX2
                        CollisionTime = Stop_TX2 - Start_TX1;
                        if CollisionTime > tmpResult(TX1,TX2,Slot_x,LeftCollisionTimeDim)
                            tmpResult(TX1,TX2,Slot_x,LeftCollisionTimeDim)= CollisionTime;
                        end
                        if CollisionTime > tmpResult(TX2,TX1,Slot_x,RightCollisonTimeDim)
                            tmpResult(TX2,TX1,Slot_x,RightCollisonTimeDim)= CollisionTime;
                        end
                    else
                        CollisionTime = Stop_TX1 - Start_TX2;
                        if CollisionTime > tmpResult(TX1,TX2,Slot_x,RightCollisonTimeDim)
                            tmpResult(TX1,TX2,Slot_x,RightCollisonTimeDim)= CollisionTime;
                        end
                        if CollisionTime > tmpResult(TX2,TX1,Slot_x,LeftCollisionTimeDim)
                            tmpResult(TX2,TX1,Slot_x,LeftCollisionTimeDim)= CollisionTime;
                        end
                    end 
                end
                    

                if Slot_x < 69
                    StartSlot_Y = 1;
                else
                    StartSlot_Y = Slot_x - 68;
                end
                for Slot_y = StartSlot_Y:Slot_x - 1
                    Start_TX2 = signals(TX2,1,Slot_x);
                    Stop_TX2 = signals(TX2,2,Slot_x);
                    Start_TX1 = signals(TX1,1,Slot_y);
                    Stop_TX1 = signals(TX1,2,Slot_y);
                    
                    if Start_TX2 < Stop_TX1 && Stop_TX2 > Start_TX1
                        tmpResult(TX1,TX2,Slot_y,CounterCollisionDim)= tmpResult(TX1,TX2,Slot_y,CounterCollisionDim) + 1; %Slot_x ;
                        tmpResult(TX2,TX1,Slot_x,CounterCollisionDim)= tmpResult(TX2,TX1,Slot_x,CounterCollisionDim) + 1; %Slot_y ;
                        if Stop_TX1 > Stop_TX2
                            CollisionTime = Stop_TX2 - Start_TX1;
                            if CollisionTime > tmpResult(TX1,TX2,Slot_y,LeftCollisionTimeDim)
                                tmpResult(TX1,TX2,Slot_y,LeftCollisionTimeDim)= CollisionTime;
                            end
                            if CollisionTime > tmpResult(TX2,TX1,Slot_x,RightCollisonTimeDim)
                                tmpResult(TX2,TX1,Slot_x,RightCollisonTimeDim)= CollisionTime;
                            end
                        else
                            CollisionTime = Stop_TX1 - Start_TX2;
                            if CollisionTime > tmpResult(TX1,TX2,Slot_y,RightCollisonTimeDim)
                                tmpResult(TX1,TX2,Slot_y,RightCollisonTimeDim)= CollisionTime;
                            end
                            if CollisionTime > tmpResult(TX2,TX1,Slot_x,LeftCollisionTimeDim)
                                tmpResult(TX2,TX1,Slot_x,LeftCollisionTimeDim)= CollisionTime;
                            end
                        end 
                    end
                end
            end
        end
    end
    Result(:,:,:,1) = tmpResult(:,:,:,1);
    Result(:,:,:,2) = tmpResult(:,:,:,2) + tmpResult(:,:,:,3);
    Result((Result(:,:,:,2)>PacketTime)+DimensionsSignals*DimensionsSignals*NumberOfSlots) = PacketTime;
end

    %% |[Start,Stop] TX1   |       [Start,Stop] TX1|                 [Start,Stop] TX1  |[Start,Stop] TX1
    %% |   [Start,Stop] TX2|[Start,Stop] TX2       |[Start,Stop] TX2                   |                 [Start,Stop] TX2
    %% |     result = 1    |        result = 1     |              result = 0           |             result = 0