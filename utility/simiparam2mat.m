
function p = simiparam2mat(tx,ty,rot,s)
    if size(s,2)>1
        sn = sin(rot); cs=cos(rot);
        p = [tx,    ty,...
            s(2)*cs,-s(1)*sn,...
            s(2)*sn, s(1)*cs];
    else
        sn = s*sin(rot); cs=s*cos(rot);
        p = [tx,ty,cs,-sn,sn,cs];
    end
    
end