function [CountSteps]= Fn_MiLTester_CountStepsInTheSignal(Signal)

   CountSteps=0;
   for i=1:(length(Signal)-1),
     if (Signal(i)~=Signal(i+1))
        CountSteps=CountSteps+1;
     end  
   end
end 