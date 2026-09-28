function [hasEnded, tBurnout] = burnEnded(thrust, time)

lastThrustIDx = find(thrust, 1, "last");

hasEnded = false(size(thrust));
tBurnout = NaN;

hasEnded(lastThrustIDx+1:end) = true;
if lastThrustIDx < numel(time)
    tBurnout = time(lastThrustIDx+1);
end

end