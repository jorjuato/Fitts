function [ma,mv] = moving_mean(x,osc)
    if nargin==1, osc=2; end
    
    len=length(x);
    ma=zeros(1,len)*NaN;
    mv=zeros(1,len)*NaN;
    [maxPeaks, minPeaks]=peakdet(x,0.05);
    peaks=sort([maxPeaks(:,1);minPeaks(:,1)]);
    peakno=length(peaks);
    win=round(osc*(len/peakno));
    for i=1:len-win
        ma(i)=nanmean(x(i:i+win));
        mv(i)=nanvar(x(i:i+win));
    end
end