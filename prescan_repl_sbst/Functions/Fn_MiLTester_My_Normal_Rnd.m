function [out]=Fn_MiLTester_My_Normal_Rnd(Miu,Sigma)    
    persistent hval
    persistent even
    if(even)
        out=hval;
        even=0;
    else
        w=0;
        while(w<=0 || w>=1)
            x=2*rand(1)-1;
            y=2*rand(1)-1;
            w=x^2+y^2;
        end
        gval=Miu+x*Sigma*sqrt(-2*log(w)/w);
        hval=Miu+y*Sigma*sqrt(-2*log(w)/w);
        even=1;
        out=gval;
        if out>1
            out=1;
        end
        if out <-1
            out=-1;
        end
     
    end
    
end