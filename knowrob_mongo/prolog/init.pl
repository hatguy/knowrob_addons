%%
%% Copyright (C) 2013 by Moritz Tenorth
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%

:- register_ros_package(ias_knowledge_base).
:- register_ros_package(knowrob_mongo).

:- use_module(library(knowrob_mongo)).

:- rdf_db:rdf_register_ns(knowrob, 'http://ias.cs.tum.edu/kb/knowrob.owl#', [keep(true)]).
:- rdf_db:rdf_register_ns(srdl2, 'http://ias.cs.tum.edu/kb/srdl2.owl#', [keep(true)]).
:- rdf_db:rdf_register_ns(srdl2comp, 'http://ias.cs.tum.edu/kb/srdl2-comp.owl#', [keep(true)]).
:- rdf_db:rdf_register_ns(srdl2cap, 'http://ias.cs.tum.edu/kb/srdl2-cap.owl#', [keep(true)]).
:- rdf_db:rdf_register_ns(pr2, 'http://ias.cs.tum.edu/kb/PR2.owl#', [keep(true)]).

:- rdf_db:rdf_register_ns(log, 'http://ias.cs.tum.edu/kb/cram_log.owl#', [keep(true)]).
