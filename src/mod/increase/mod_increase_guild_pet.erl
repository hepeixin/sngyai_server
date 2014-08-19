-module(mod_increase_guild_pet).
-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common.hrl").
%% --------------------------------------------------------------------

%% API
-export([
  get_info/0,
  new_id/0
]).

%% External exports
-export([
  start_link/0
]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ID状态信息
-record(state, {
  id_index = 1,        %% 当前索引值
  id_max = 1                   %% id最大值
}).

%% ====================================================================
%% External functions
%% ====================================================================

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], ?Public_Service_Options).


%% ====================================================================
%% 外部API接口
%% ====================================================================
%% 获取进程State信息
get_info() ->
  State = gen_server:call(?MODULE, 'get_info'),
  State.

%% 获取副本自增Id
new_id() ->
  AutoId = gen_server:call(?MODULE, 'get_new_id'),
  AutoId.

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
  put(tag, ?MODULE),
  process_flag(trap_exit, true),
  % 初始化ID
  {ok, Id_Index, Id_Max} = init_id(),
  % 服务启动的时候保证还有五千万的空间,否则不让启动
  if Id_Max - Id_Index < 50000000 -> throw("guild_pet key overflow warning!"); true -> skip end,

  State = #state{
    id_index = Id_Index,
    id_max = Id_Max
  },
  {ok, State}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(Info, _From, State) ->
  try
    do_call(Info, _From, State)
  catch
    _:Reason ->
      Stacktrace = erlang:get_stacktrace(),
      ?Error(increase_logger, "mod_increase_guild handle_call is Info:~p, Reason:~p, Trace:~p, State:~p", [Info, Reason, Stacktrace, State]),
      ?T("*****Error mod_increase_guild handle_call info: ~p,~n reason:~p,~n stacktrace:~p", [Info, Reason, Stacktrace]),
      {reply, ok, State}
  end.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Info, State) ->
  try
    do_cast(Info, State)
  catch
    _:Reason ->
      Stacktrace = erlang:get_stacktrace(),
      ?Error(increase_logger, "mod_increase_guild handle_cast is Info:~p, Reason:~p, Trace:~p, State:~p", [Info, Reason, Stacktrace, State]),
      ?T("*****Error mod_increase_guild handle_cast info: ~p,~n reason:~p,~n stacktrace:~p", [Info, Reason, Stacktrace]),
      {noreply, State}
  end.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(Info, State) ->
  try
    do_info(Info, State)
  catch
    _:Reason ->
      Stacktrace = erlang:get_stacktrace(),
      ?Error(increase_logger, "mod_increase_guild handle_info is Info:~p, Reason:~p, Trace:~p, State:~p", [Info, Reason, Stacktrace, State]),
      ?T("*****Error mod_increase_guild handle_info info: ~p,~n reason:~p,~n stacktrace:~p", [Info, Reason, Stacktrace]),
      {noreply, State}
  end.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
  ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

%%---------------------do_call--------------------------------
%% 获取进程State
do_call('get_info', _, State) ->
  {reply, State, State};
%% 获取新ID
do_call('get_new_id', _, State) ->
  AutoId = State#state.id_index + 1,
  case AutoId >= State#state.id_max of
    true ->
      ?T("guild_increase overflow current_id:~p,maxid:~p", [AutoId, State#state.id_max]),
      ?Error(increase_logger, "guild_increase overflow current_id:~p,maxid:~p", [AutoId, State#state.id_max]);
    false ->
      skip
  end,
  NewState = State#state{id_index = AutoId},
  {reply, AutoId, NewState};

do_call(Info, _, State) ->
  ?Error(increase_logger, "mod_increase call is not match:~w", [Info]),
  {reply, ok, State}.


%%---------------------do_cast--------------------------------
do_cast(Info, State) ->
  ?Error(increase_logger, "mod_increase cast is not match:~w", [Info]),
  {noreply, State}.

%%---------------------do_info--------------------------------
do_info(Info, State) ->
  ?Error(increase_logger, "mod_increase info is not match:~w", [Info]),
  {noreply, State}.


%%%-------------------------------------------------------------------
%% 内部函数
%%%-------------------------------------------------------------------

init_id() ->
  Min = lib_config:get_subsection_min(),
  Max = lib_config:get_subsection_max(),
  Table_Name = guild_pet,
  case ?DB_GAME:select_one(Table_Name, "Max(id)", [{id, ">=", Min}, {id, "<", Max}]) of
    {scalar, undefined} ->%没有找到，初始化 ID起始值
      FirstID = Min,
      {ok, FirstID, Max};
    {scalar, MaxIdVal} ->%数据库表中目前最大ID值
      {ok, MaxIdVal, Max};
    {error, Reason} ->
      {error, Reason}
  end.
