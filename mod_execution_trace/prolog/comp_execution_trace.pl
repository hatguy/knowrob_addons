:- module(comp_execution_trace,
    [
     	task/1,
	subtask/2,
	subtask_all/2,
      	task_goal/2,
	task_start/2,
	task_end/2,
	cram_holds/2,
	returned_value/2,
	computable_belief/3,
      	computable_truth/3,
	computable_time_check/3,
	computable_location_check/3,
	computable_perception_time_instances/2,
	computable_perception_object_instances/2,
	belief_at/2,
	truth_at/2,
	failure_class/2,
	failure_task/2,
	failure_attribute/3
	%task_status done
	%belief_at done
	%occur
	%holds_at _ during _tt(throughout) different predicates or single
	
    ]).
:- use_module(library('semweb/rdfs')).
:- use_module(library('semweb/owl')).
:- use_module(library('semweb/rdf_db')).
:- use_module(library('semweb/rdfs_computable')).
:- use_module(library('thea/owl_parser')).


:- rdf_db:rdf_register_ns(knowrob,  'http://ias.cs.tum.edu/kb/knowrob.owl#',  [keep(true)]).
:- rdf_db:rdf_register_ns(modexecutiontrace, 'http://ias.cs.tum.edu/kb/knowrob_cram.owl#', [keep(true)]).

% define holds as meta-predicate and allow the definitions
% to be in different parts of the source file
:- meta_predicate cram_holds(0, ?, ?).
:- discontiguous cram_holds/2.


% define predicates as rdf_meta predicates
% (i.e. rdf namespaces are automatically expanded)
:-  rdf_meta
    task(r),
    subtask(r,r),
    subtask_all(r,r),
    task_goal(r,r),
    task_start(r,r),
    task_end(r,r),
    cram_holds(r,r),
    returned_value(r,r),
    computable_belief(r,r,r),
    computable_truth(r,r,r),
    computable_time_check(r,r,r),
    computable_location_check(r,r,r),
    computable_perception_time_instance(r,r),
    computable_perception_object_instance(r,r),
    belief_at(r,r),
    truth_at(r,r),
    failure_class(r,r),
    failure_task(r,r),
    failure_attribute(r,r,r).



task(Task) :-	
	rdf_has(Task, rdf:type, A),
	rdf_individual_of(A, modexecutiontrace:'CRAMAction').

subtask(Task, Subtask) :-
	task(Task),
	task(Subtask),
	rdf_has(Task, knowrob:'subAction', Subtask).

subtask_all(Task, Subtask) :-
	subtask(Task, Subtask);	

	nonvar(Task),
	task(Task),
	task(Subtask),
	subtask(Task, A),
	subtask_all(A, Subtask);


	nonvar(Subtask),
	task(Task),
	task(Subtask),
	subtask(A, Subtask),
	subtask_all(Task, A);


	var(Task),
	var(Subtask),
	task(Task),
	task(Subtask),
	subtask(Task, A),
	subtask_all(A, Subtask).

task_goal(Task, Goal) :-
	task(Task),
	rdf_has(Task, rdf:type, Goal);

	% task(Task),
	% rdf_has(Task, rdf:type, Goal),
	% Goal = modexecutiontrace:'AchieveGoalAction';

	task(Task),
	rdf_has(Task, rdf:type, Goal),
	rdf_has(Goal, rdfs:subClassOf, modexecutiontrace:'AchieveGoalAction');

	task(Task),
	rdf_has(Task, rdf:type, Goal),
	rdf_has(Goal, rdfs:subClassOf, B),
	rdf_has(B, rdfs:subClassOf, modexecutiontrace:'AchieveGoalAction').
	
task_start(Task, Start) :-
	task(Task),
	rdf_has(Task, knowrob:'startTime', Start).

task_end(Task, End) :-
	task(Task),
	rdf_has(Task, knowrob:'endTime', End).

cram_holds(task_status(Task, Status), T):-
	nonvar(Task),	
	task(Task),
	task_start(Task, Start),
	task_end(Task, End),
	computable_time_check(Start, T, Compare_Result1),
	computable_time_check(T, End, Compare_Result2),
	term_to_atom(Compare_Result1, c1),	
	term_to_atom(Compare_Result2, c2),
	((c1 is 1) -> (((c2 is 1) -> (Status = ['Continue']);(Status = ['Done'])));(((c2 is 1) -> (Status = ['Error']); (Status = ['NotStarted']))));

	nonvar(Status),
	nonvar(T).

cram_holds(object_visible(Object, Status), T):-
	nonvar(Object),	
	nonvar(T),
	computable_belief(Object, T, Loc),
	rdf_triple(comp_spatial:'m01', Loc, Result),
	term_to_atom(Result, r),
	((r is -1) -> (Status = [true]);(Status = [false]));
	
	nonvar(Object),
	var(T),	
	computable_perception_time_instances(Object, T),
	Status = [true];

	var(Object),
	nonvar(T),	
	computable_perception_object_instances(T, Object),
	Status = [true].	

cram_holds(object_placed_at(Object, Loc), T):-
	computable_belief(Object, T, Actual_Loc),
	computable_time_check(Loc, Actual_Loc, Compare_Result),
	term_to_atom(Compare_Result, r),
	((r is 0) -> (true);(false)).

returned_value(Task, Obj) :-
	rdf_has(Task, rdf:type, knowrob:'VisualPerception'),
	rdf_has(Task, knowrob:'detectedObject', Obj).

belief_at(Loc, Time) :-
	computable_belief(first(Loc), Time, second(Loc)).

truth_at(Loc, Time) :-
	computable_belief(first(Loc), Time, second(Loc)).

computable_belief(Object, Time, Loc) :-
    
    % create ROS client object
    jpl_new('edu.tum.cs.ias.knowrob.mod_execution_trace.ROSClient_low_level', ['my_low_level'], Client),

    jpl_call(Client, 'getBelief', [], Localization_Array),

    jpl_array_to_list(Localization_Array, LocList),

    [M00, M01, M02, M03, M10, M11, M12, M13, M20, M21, M22, M23, M30, M31, M32, M33] = LocList,

    atomic_list_concat(['rotMat3D_',M00,'_',M01,'_',M02,'_',M03,'_',M10,'_',M11,'_',M12,'_',M13,'_',M20,'_',M21,'_',M22,'_',M23,'_',M30,'_',M31,'_',M32,'_',M33], LocIdentifier),

    atom_concat('http://ias.cs.tum.edu/kb/knowrob.owl#', LocIdentifier, Loc),
    rdf_assert(Loc, rdf:type, knowrob:'RotationMatrix2D').

computable_truth(Object, Time, Loc) :-
    
    % create ROS client object
    jpl_new('edu.tum.cs.ias.knowrob.mod_execution_trace.ROSClient_low_level', ['my_low_level'], Client),

    term_to_atom(Time, t),

    term_to_atom(Object, o),

    jpl_call(Client, 'getReal', [o, t], Localization_Array),

    jpl_array_to_list(Localization_Array, LocList),

    [M00, M01, M02, M03, M10, M11, M12, M13, M20, M21, M22, M23, M30, M31, M32, M33] = LocList,

    atomic_list_concat(['rotMat3D_',M00,'_',M01,'_',M02,'_',M03,'_',M10,'_',M11,'_',M12,'_',M13,'_',M20,'_',M21,'_',M22,'_',M23,'_',M30,'_',M31,'_',M32,'_',M33], LocIdentifier),

    atom_concat('http://ias.cs.tum.edu/kb/knowrob.owl#', LocIdentifier, Loc),
    rdf_assert(Loc, rdf:type, knowrob:'RotationMatrix3D').

computable_time_check(Time1, Time2, Compare_Result) :-
    
    % create ROS client object
    jpl_new('edu.tum.cs.ias.knowrob.mod_execution_trace.ROSClient_low_level', ['my_low_level'], Client),

    term_to_atom(Time1, t1),

    term_to_atom(Time2, t2),

    jpl_call(Client, 'timeComparison', [t1, t2], Result),

    jpl_array_to_list(Result, ResultList),

    [Compare_Result] = ResultList.

computable_location_check(L1, L2, Compare_Result) :-
    
    % create ROS client object
    jpl_new('edu.tum.cs.ias.knowrob.mod_execution_trace.ROSClient_low_level', ['my_low_level'], Client),

    term_to_atom(L1, l1),

    term_to_atom(L2, l2),

    jpl_call(Client, 'timeComparison', [l1, l2], Result),

    jpl_array_to_list(Result, ResultList),

    [Compare_Result] = ResultList.

computable_perception_time_instances(Object, TimeList) :-

    % create ROS client object
    jpl_new('edu.tum.cs.ias.knowrob.mod_execution_trace.ROSClient_low_level', ['my_low_level'], Client),

    term_to_atom(Object, o1),

    jpl_call(Client, 'getPerceptionTimeStamps', [o1], Times),

    jpl_array_to_list(Times, TimeList).

computable_perception_object_instances(Time, ObjectList) :-

    % create ROS client object
    jpl_new('edu.tum.cs.ias.knowrob.mod_execution_trace.ROSClient_low_level', ['my_low_level'], Client),

    term_to_atom(Object, o1),

    jpl_call(Client, 'getPerceptionObjects', [o1], Objects),

    jpl_array_to_list(Objects, ObjectList).

failure_class(Error, Class) :-	
	rdf_has(Error, rdf:type, Class),
	rdf_individual_of(Class, modexecutiontrace:'CRAMFailure').

failure_task(Error, Task) :-
	task(Task),	
	failure_class(Error, Class),
	rdf_has(Task, modexecutiontrace:'eventFailure', Error).

failure_attribute(Error,AttributeName,Value) :-
	failure_class(Error, Class),
	rdf_has(Error, AttributeName, Value).
