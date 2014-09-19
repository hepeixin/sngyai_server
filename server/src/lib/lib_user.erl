%%%-------------------------------------------------------------------
%%% @author Yudong
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 八月 2014 22:13
%%%-------------------------------------------------------------------
-module(lib_user).
-author("Yudong").

-include("common.hrl").
-include("record.hrl").


%% API
-export([
  login/1,
  add_score/2,
  set_tokens/2,
  get_tokens/1,
  t/0
]).

%%创建用户
create_role(Idfa) ->
    NewUser =
      #user{
        id = Idfa,
        score_current = 0,
        score_total = 0,
        account = ""
      },
    ets:insert(?ETS_ONLINE, NewUser),
    db_agent_user:create(NewUser),
    "ok".

create_role_with_tokens(Idfa, Tokens) ->
  NewUser =
    #user{
      id = Idfa,
      score_current = 0,
      score_total = 0,
      account = "",
      tokens = Tokens
    },
  ets:insert(?ETS_ONLINE, NewUser),
  db_agent_user:create(NewUser),
  "ok".

%%登录
login(UserId) ->
  {ScoreCurrent, ScoreTotal} =
    case ets:lookup(?ETS_ONLINE, UserId) of
    [#user{score_current = SC, score_total = ST}|_] ->
      {SC, ST};
    _Other -> %用户不存在，创建一个
      create_role(UserId),
      {0, 0}
  end,
  Result =
    [
      {"score_current", lib_util_type:term_to_string(ScoreCurrent)},
      {"score_total", lib_util_type:term_to_string(ScoreTotal)}
    ],
  lib_util_string:key_value_to_json(Result).

%%完成任务，更新积分
%%UserId用户唯一标识T
%%Score获得积分
add_score(UserId, Score) ->
  case ets:lookup(?ETS_ONLINE, UserId) of
    [#user{score_current = SC, score_total = ST} = UserInfo|_] ->
      ScoreCurrent = SC + Score,
      ScoreTotal = ST + Score,
      NewUserInfo =
        UserInfo#user{
          score_current = ScoreCurrent,
          score_total = ScoreTotal
        },
      ets:insert(?ETS_ONLINE, NewUserInfo),
      db_agent_user:update_score(UserId, ScoreCurrent, ScoreTotal);
    _Other ->
      ?T("add_score_error:~p~n ~p~n", [_Other, ets:tab2list(?ETS_ONLINE)]),
      ?Error(default_logger, "add_score_error: ~p~n ~p~n ~p~n", [UserId, _Other, ets:tab2list(?ETS_ONLINE)])
  end.

%%更新用户tokens
set_tokens(UserId, Tokens) ->
  case ets:lookup(?ETS_ONLINE, UserId) of
    [#user{} = UserInfo|_] ->
      NewUserInfo = UserInfo#user{tokens = Tokens},
      ets:insert(?ETS_ONLINE, NewUserInfo),
      db_agent_user:set_tokens(UserId, Tokens);
    _Other ->
      create_role_with_tokens(UserId, Tokens)
  end.

get_tokens(UserId) ->
  case ets:lookup(?ETS_ONLINE, UserId) of
    [#user{tokens = Tokens}|_] when Tokens =/= undefined->
      Tokens;
    _Other ->
      []
  end.


t() ->
  create_role("1A2C").





