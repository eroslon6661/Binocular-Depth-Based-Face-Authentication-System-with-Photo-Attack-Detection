function check_embeddings_matlab(folder)
% Independent scalar metric calculation in MATLAB; no model replacement.
% check_embeddings_matlab('.../full_model_compare_02')
names = {'reference_stage_embedding.bin','reference_end_to_end_embedding.bin'};
board = read_i8(fullfile(folder,'board_embedding.bin'));
results = struct();
for k=1:numel(names)
    ref=read_i8(fullfile(folder,names{k}));
    assert(numel(board)==512 && numel(ref)==512);
    d=abs(board-ref);
    r=struct('different',sum(d~=0),'max_abs',max(d),...
        'mean_abs',mean(d),'rmse',sqrt(mean(d.^2)),...
        'cosine',dot(board,ref)/(norm(board)*norm(ref)));
    results.(sprintf('comparison_%d',k))=r;
end
results.matlab_version=version;
results.scope='Metrics only; one captured frame, not population recognition accuracy';
f=fopen(fullfile(folder,'matlab_metrics.json'),'w');assert(f>=0);
fprintf(f,'%s\n',jsonencode(results,PrettyPrint=true));fclose(f);
disp(results);
end
function v=read_i8(path)
f=fopen(path,'rb');assert(f>=0);v=fread(f,Inf,'int8=>double');fclose(f);
end
