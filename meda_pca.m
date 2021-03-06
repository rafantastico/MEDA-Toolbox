
function [meda_map,meda_dis,ord] = meda_pca(x,pcs,prep,thres,opt,label,vars)

% Missing data methods for exploratory data analysis in PCA. The original
% paper is Chemometrics and Intelligent Laboratory Systems 103(1), 2010, pp.
% 8-18. This algorithm follows the suggested computation by Arteaga in his
% technical report "A Note on MEDA", attached to the toolbox, which
% makes use of the covariance matrices.
%
% [meda_map,meda_dis,ord] = meda_pca(x,pcs) % minimum call
% [meda_map,meda_dis,ord] = meda_pca(x,pcs,prep,thres,opt,label,vars) %complete call
%
%
% INPUTS:
%
% x: (NxM) billinear data set under analysis
%
% pcs: (1xA) Principal Components considered (e.g. pcs = 1:2 selects the
%   first two PCs)
%
% prep: (1x1) preprocesing of the data
%       0: no preprocessing.
%       1: mean centering.
%       2: autoscaling (default)  
%
% thres: (1x1) threshold for the discretized MEDA matrix (0.1 by default)
%
% opt: (1x1) options for data plotting.
%       0: no plots.
%       1: plot MEDA matrix (default)
%       2: plot discretized MEDA matrix
%       3: plot MEDA matrix seriated 
%       4: plot discretized MEDA matrix seriated
%
% label: (Mx1) name of the variables (numbers are used by default), eg.
%   num2str((1:M)')'
%
% vars: (1xS) Subset of variables to plot (1:M by default)
%
%
% OUTPUTS:
%
% meda_map: (MxM) MEDA matrix.
%
% meda_dis: (MxM) discretized MEDA matrix.
%
% ord: (1xS) order of shown variables.
%
%
% coded by: Jos� Camacho P�ez (josecamacho@ugr.es)
% last modification: 20/Oct/14.
%
% Copyright (C) 2014  University of Granada, Granada
% Copyright (C) 2014  Jos� Camacho P�ez
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% Parameters checking

if nargin < 2, error('Error in the number of arguments.'); end;
s = size(x);
if s(1) < 1 || s(2) < 1 || ndims(x)~=2, error('Error in the dimension of the arguments.'); end;
if nargin < 3, prep = 2; end;
if nargin < 4, thres=0.1; end; 
if nargin < 5, opt = 1; end;
if nargin < 6 || isempty(label)
    label=num2str((1:s(2))'); 
else
    if ndims(label)==2 & find(size(label)==max(size(label)))==2, label = label'; end
    if size(label,1)~=s(2), error('Error in the dimension of the arguments.'); end;
end
if nargin < 7, vars = 1:s(2); end;

%% Main code

ord = vars;

x2 = preprocess2D(x,prep);

P = pca_pp(x2,max(pcs));
P = P(:,pcs);
        
[meda_map,meda_dis] = meda(x2'*x2,P,P,thres);
    
%% Show results

if opt,
    switch opt,
        case 2
            map1 = meda_dis;
            ord = 1:s(2);
        case 3
            [map1, ord] = seriation(meda_map);
        case 4
            [map1, ord] = seriation(meda_dis);
        otherwise
            map1 = meda_map;
            ord = 1:s(2);
    end
    
    varso = [];
    for i=1:length(vars),
        j=find(vars(i)==ord,1);
        varso=[varso j];
    end
    varso = sort(varso);
    
    if ~exist('label')
        label = num2str(ord');
    end
    
    plot_map(map1(varso,varso),label(ord(varso),:));
    
    ord = ord(varso);
end

        