function [site] = site_spec(name)
switch name
    case "SRA"
        site.elev = 0;
        % Add more later once its needed in other modeling
    case "Midland"
        site.elev = 890; % Update per ESRA site announcment
    otherwise
        error("Unsopperted Launch Site, add manually or check input spelling")
end