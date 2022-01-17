function addUnits(this,prs)

viconNlxLag = getViconNlxLag(prs.neuralRawPath,prs.viconPath);
[sua,mua] = getUnitsPhy(prs);

if ~isempty([sua.spkTimes])
    for i = 1:numel(sua)
%         if i < 2
%             this.units = unit('singleUnit',sua(i),30000,viconNlxLag);
%         else
            this.units(end+1) = unit('singleUnit',sua(i),prs.srNlx,viconNlxLag);
%         end
        this.units(end).addTrials(this.units(end).block.spkTimes,this.behaviors.trials,this.behaviors.block);
    end
end


if ~isempty([mua.spkTimes])
    for i = 1:numel(mua)
        this.units(end+1) = unit('multiUnit',mua(i),prs.srNlx,viconNlxLag);
        this.units(end).addTrials(this.units(end).block.spkTimes,this.behaviors.trials,this.behaviors.block);
    end
end


end