libName = 'epanet2';hfileName = 'epanet2.h';
loadlibrary(libName,hfileName);
errcode = calllib(libName,'ENopen','wenti.inp','wenti.rpt','wenti.put');
if errcode~=0
    keyboard
end
id=libpointer('cstring','addP-26-2');
index =libpointer('int32Ptr',0);
[code,id,index]=calllib('epanet2','ENgetlinkindex',id,index);
errcode=calllib('epanet2','ENsetlinkvalue',index,4,0)
errcode=calllib('epanet2','ENsetlinkvalue',index,11,0)
errcode=calllib('epanet2','ENsetlinkvalue',index,12,12)
calllib('epanet2','ENsaveinpfile','wenti1.inp')