function [o,o2] = readELE_Ms(varargin)
    % readELE reads ELE file
    %
    % INPUT
    %   filename     -- if file is named as 'abc.ele', a filename='abc'
    %                   is required
    %   outputnumber -- number of result extracted, this is useful when
    %                   output file is huge
    %   outputstart  -- (not implimented yet) the start of the result
    %
    % OUTPUT
    % o  -- a struct the same size as the number of output.
    % o2 -- a struct extracting headers with the extraction inf
    %
    % Example:
    % [eledata,elehead]=readELE('project','outputnumber',3);
    %    Purpose: parsing 'project.ele' (or 'project.ELE')
    %            only the first three result gets extracted

    % a string storing the caller functions
    caller = dbstack('-completenames'); caller = caller.name;

    o2.varargin       = varargin;
    [fname, varargin] = getNext(varargin,'char','');
    % an option to see whether use inp contents to guide the reading process
    % a hard reading process will be conducted if left empty
    [output_no,  varargin]   = getProp(varargin,'outputnumber',0);
    [output_from,  varargin] = getProp(varargin,'outputfrom',0);
    [inpObj,  varargin]      = getProp(varargin,'inpObj',[]);
    o2.output_no             = output_no;
    fn                       = fopen([fname,'.ELE']);

    if fn==-1
        fprintf(1,'%s : Trying to open %s .ele\n',caller,fname);
        fn=fopen([fname,'.ele']);
        if fn==-1
            fprintf('%s: file ele found!!\n',caller,fname);
            o=-1;o2=-1;
            return
        end
    end

    o2.title1 = getNextLine(fn,'criterion',...
        'with','keyword','## ','operation','delete');
    o2.title2 = getNextLine(fn,'criterion',...
        'with','keyword','## ','operation','delete');

    % ---------------- Parsing the line with node, element info-----------------
    o2.MeshInfo =getNextLine(fn,'criterion','equal','keyword','## ');
    tmp=regexprep(o2.MeshInfo,{'#','(',')','\,','*','='},{'','','','','',''});
    tmp2=textscan(tmp,'%s %s %s ');
    if strcmp(tmp2{1}{1},'2-D') && strcmp(tmp2{2}{1},'REGULAR')
        tmp=textscan(tmp,'%s %s %s %f %f %f %*s %f %*s');
        % how to realize this by one-liner
        %  [o2.mshtyp{1} o2.mshtyp{2} ] = deal(tmp{1:2}{1});
        [o2.nn1,o2.nn2,o2.ne,o2.nn ]    = deal(tmp{4:7});
    elseif strcmp(tmp2{1}{1},'2-D') && strcmp(tmp2{2}{1},'IRREGULAR')
        tmp=textscan(tmp,'%s %s %s %f %s %f %s ');
        [o2.nn ]    = deal(tmp{4});
    elseif strcmp(tmp2{1}{1},'3-D') && strcmp(tmp2{2}{1},'BLOCKWISE')
        tmp=textscan(tmp,'%s %s %s %f %f %f %f %*s %f %*s');
        [o2.nn1,o2.nn2,o2.nn3,o2.nn,o2.ne ]    = deal(tmp{4:8});
    elseif strcmp(tmp2{1}{1},'3-D') && strcmp(tmp2{2}{1},'LAYERED')
        tmp=textscan(tmp,'%s %s %s %s %f %f %f %*s %f %*s');
        [o2.nn1,o2.nn2,o2.nn3,o2.nn,o2.ne ]    = deal(tmp{4:8});
    end
    o2.mshtyp{1}                    = tmp{1}{1};
    o2.mshtyp{2}                    = tmp{2}{1};

    % ---------------- parsing the number of results    ------------------------
    tmp = getNextLine(fn,'criterion','with','keyword',...
        '## VELOCITYRESULTS','operation','delete');
    tmp           = textscan(tmp,'%f ');
    o2.ktprn      = tmp{1};  % expected no. time steps
    if output_no ~= 0;
        output_no   = min(o2.ktprn,output_no);
    else
        output_no = o2.ktprn;
    end

    % Adapted from Jiaxu
    % ---------------- Parsing simulation results -----------------------------
    fprintf(1,'coastal is parsing the %g of %g outputs\n', output_no,o2.ktprn);
    for n=1:output_no
        fprintf('.');
        if rem(n,50)==0; fprintf('%d\n',n);   end
        tmp       = getNextLine(fn,'criterion','with','keyword','## TIME STEP');
        if tmp  ~= -1
            tmp = regexprep(tmp,{'## TIME STEP','Duration:','sec','Time:'}...
                ,{'','','',''});
            tmp   = textscan(tmp,'%f %f %f');
            [ o(n).itout,o(n).durn,o(n).tout] = deal(tmp{:});

            tmp = getNextLine(fn,'criterion','without'...
                ,'keyword','## ==');
            % remove '## ' at the beginning
            tmp=tmp(4:end);

            o(n).label = getOutputLabelName( tmp );
            fmt        = repmat('%f ',1, length(o(n).label));
            o(n).terms = textscan(fn,fmt,o2.nn);
        else
            fprintf(1,['WARNING FROM coastal: Simulation is not completed\n %g'...
                'out of %g outputs extracted\n'],n,o2.ktprn);
            return
        end % if condition
    end  % n loops
    fprintf('coastal: Parsed %g of %g outputs\n', output_no,o2.ktprn);
    fclose all;