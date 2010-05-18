-module(jsx_utf8).

-export([start/4]).

-include("jsx_common.hrl").


callback(eof, Callbacks) ->
    lists:reverse(Callbacks);
callback(Event, Callbacks) ->
    [Event] ++ Callbacks.
    

%% this code is mostly autogenerated and mostly ugly. apologies. for more insight on
%%   Callbacks or Opts, see the comments accompanying callback/2 (in this file) and
%%   parse_opts/1 (in jsx.erl). Stack is a stack of flags used to track depth and to
%%   keep track of whether we are returning from a value or a key inside objects. all
%%   pops, peeks and pushes are inlined. the code that handles naked values and comments
%%   is not optimized by the compiler for efficient matching, but you shouldn't be using
%%   naked values or comments anyways, they are horrible and contrary to the spec.

start(<<?start_object/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    object(Rest, [key|Stack], callback(start_object, Callbacks), Opts);
start(<<?start_array/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    array(Rest, [array|Stack], callback(start_array, Callbacks), Opts);
start(<<?quote/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.naked_values == true ->
    string(Rest, Stack, Callbacks, Opts, []);
start(<<$t/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.naked_values == true ->
    tr(Rest, Stack, Callbacks, Opts);
start(<<$f/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.naked_values == true ->
    fa(Rest, Stack, Callbacks, Opts);
start(<<$n/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.naked_values == true ->
    nu(Rest, Stack, Callbacks, Opts);
start(<<?negative/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.naked_values == true ->
    negative(Rest, Stack, Callbacks, Opts, "-");
start(<<?zero/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.naked_values == true ->
    zero(Rest, Stack, Callbacks, Opts, "0");
start(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts) when ?is_nonzero(S), Opts#opts.naked_values == true ->
    integer(Rest, Stack, Callbacks, Opts, [S]);
start(<<?solidus/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.comments == true ->
    maybe_comment(Rest, fun(Resume) -> start(Resume, Stack, Callbacks, Opts) end);
start(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts) when ?is_whitespace(S) -> 
    start(Rest, Stack, Callbacks, Opts);
start(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> start(Stream, Stack, Callbacks, Opts) end.

    
maybe_done(<<?end_object/utf8, Rest/binary>>, [object|Stack], Callbacks, Opts) ->
    maybe_done(Rest, Stack, callback(end_object, Callbacks), Opts);
maybe_done(<<?end_array/utf8, Rest/binary>>, [array|Stack], Callbacks, Opts) ->
    maybe_done(Rest, Stack, callback(end_array, Callbacks), Opts);
maybe_done(<<?comma/utf8, Rest/binary>>, [object|Stack], Callbacks, Opts) ->
    key(Rest, [key|Stack], Callbacks, Opts);
maybe_done(<<?comma/utf8, Rest/binary>>, [array|_] = Stack, Callbacks, Opts) ->
    value(Rest, Stack, Callbacks, Opts);
maybe_done(<<?solidus/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.comments == true ->
    maybe_comment(Rest, fun(Resume) -> maybe_done(Resume, Stack, Callbacks, Opts) end);
maybe_done(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts) when ?is_whitespace(S) ->
    maybe_done(Rest, Stack, Callbacks, Opts);
maybe_done(<<>>, [], Callbacks, _Opts) ->
    callback(eof, Callbacks);  
maybe_done(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> maybe_done(Stream, Stack, Callbacks, Opts) end.


object(<<?end_object/utf8, Rest/binary>>, [key|Stack], Callbacks, Opts) ->
    maybe_done(Rest, Stack, callback(end_object, Callbacks), Opts);
object(<<?quote/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    string(Rest, Stack, Callbacks, Opts, []);
object(<<?solidus/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.comments == true ->
    maybe_comment(Rest, fun(Resume) -> object(Resume, Stack, Callbacks, Opts) end);
object(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts) when ?is_whitespace(S) ->
    object(Rest, Stack, Callbacks, Opts);
object(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> object(Stream, Stack, Callbacks, Opts) end.
        
        
array(<<?quote/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    string(Rest, Stack, Callbacks, Opts, []);
array(<<?start_object/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    object(Rest, [key|Stack], callback(start_object, Callbacks), Opts);
array(<<?start_array/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    array(Rest, [array|Stack], callback(start_array, Callbacks), Opts);
array(<<?end_array/utf8, Rest/binary>>, [array|Stack], Callbacks, Opts) ->
    maybe_done(Rest, Stack, callback(end_array, Callbacks), Opts);
array(<<$t/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    tr(Rest, Stack, Callbacks, Opts);
array(<<$f/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    fa(Rest, Stack, Callbacks, Opts);
array(<<$n/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    nu(Rest, Stack, Callbacks, Opts);
array(<<?negative/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    negative(Rest, Stack, Callbacks, Opts, "-");
array(<<?zero/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    zero(Rest, Stack, Callbacks, Opts, "0");
array(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts) when ?is_nonzero(S) ->
    integer(Rest, Stack, Callbacks, Opts, [S]);
array(<<?solidus/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.comments == true ->
    maybe_comment(Rest, fun(Resume) -> array(Resume, Stack, Callbacks, Opts) end);
array(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts) when ?is_whitespace(S) -> 
    array(Rest, Stack, Callbacks, Opts);
array(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> array(Stream, Stack, Callbacks, Opts) end.  

        
value(<<?quote/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    string(Rest, Stack, Callbacks, Opts, []);
value(<<?start_object/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    object(Rest, [key|Stack], callback(start_object, Callbacks), Opts);
value(<<?start_array/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    array(Rest, [array|Stack], callback(start_array, Callbacks), Opts);
value(<<$t/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    tr(Rest, Stack, Callbacks, Opts);
value(<<$f/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    fa(Rest, Stack, Callbacks, Opts);
value(<<$n/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    nu(Rest, Stack, Callbacks, Opts);
value(<<?negative/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    negative(Rest, Stack, Callbacks, Opts, "-");
value(<<?zero/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    zero(Rest, Stack, Callbacks, Opts, "0");
value(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts) when ?is_nonzero(S) ->
    integer(Rest, Stack, Callbacks, Opts, [S]);
value(<<?solidus/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.comments == true ->
    maybe_comment(Rest, fun(Resume) -> value(Resume, Stack, Callbacks, Opts) end);
value(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts) when ?is_whitespace(S) -> 
    value(Rest, Stack, Callbacks, Opts);
value(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> value(Stream, Stack, Callbacks, Opts) end.
      

colon(<<?colon/utf8, Rest/binary>>, [key|Stack], Callbacks, Opts) ->
    value(Rest, [object|Stack], Callbacks, Opts);
colon(<<?solidus/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.comments == true ->
    maybe_comment(Rest, fun(Resume) -> colon(Resume, Stack, Callbacks, Opts) end);
colon(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts) when ?is_whitespace(S) ->
    colon(Rest, Stack, Callbacks, Opts);
colon(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> colon(Stream, Stack, Callbacks, Opts) end.
  
        
key(<<?quote/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    string(Rest, Stack, Callbacks, Opts, []);
key(<<?solidus/utf8, Rest/binary>>, Stack, Callbacks, Opts) when Opts#opts.comments == true ->
    maybe_comment(Rest, fun(Resume) -> key(Resume, Stack, Callbacks, Opts) end);
key(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts) when ?is_whitespace(S) ->
    key(Rest, Stack, Callbacks, Opts);
key(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> key(Stream, Stack, Callbacks, Opts) end.
      
      
%% string has an additional parameter, an accumulator (Acc) used to hold the intermediate
%%   representation of the string being parsed. using a list of integers representing
%%   unicode codepoints is faster than constructing binaries, many of which will be
%%   converted back to lists by the user anyways.
        
string(<<?quote/utf8, Rest/binary>>, [key|_] = Stack, Callbacks, Opts, Acc) ->
    colon(Rest, Stack, callback({key, lists:reverse(Acc)}, Callbacks), Opts);
string(<<?quote/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    maybe_done(Rest, Stack, callback({string, lists:reverse(Acc)}, Callbacks), Opts);
string(<<?rsolidus/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    escape(Rest, Stack, Callbacks, Opts, Acc);
string(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when ?is_noncontrol(S) ->
    string(Rest, Stack, Callbacks, Opts, [S] ++ Acc);
string(<<>>, Stack, Callbacks, Opts, Acc) ->
    fun(Stream) -> string(Stream, Stack, Callbacks, Opts, Acc) end.


%% only thing to note here is the additional accumulator passed to escaped_unicode used
%%   to hold the codepoint sequence. unescessary, but nicer than using the string 
%%   accumulator. 
    
escape(<<"b"/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    string(Rest, Stack, Callbacks, Opts, "\b" ++ Acc);
escape(<<"f"/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    string(Rest, Stack, Callbacks, Opts, "\f" ++ Acc);
escape(<<"n"/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    string(Rest, Stack, Callbacks, Opts, "\n" ++ Acc);
escape(<<"r"/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    string(Rest, Stack, Callbacks, Opts, "\r" ++ Acc);
escape(<<"t"/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    string(Rest, Stack, Callbacks, Opts, "\t" ++ Acc);
escape(<<"u"/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    escaped_unicode(Rest, Stack, Callbacks, Opts, Acc, []);      
escape(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) 
        when S =:= ?quote; S =:= ?solidus; S =:= ?rsolidus ->
    string(Rest, Stack, Callbacks, Opts, [S] ++ Acc);
escape(<<>>, Stack, Callbacks, Opts, Acc) ->
    fun(Stream) -> escape(Stream, Stack, Callbacks, Opts, Acc) end.
    

%% this code is ugly and unfortunate, but so is json's handling of escaped unicode
%%   codepoint sequences. if the ascii option is present, the sequence is converted
%%   to a codepoint and inserted into the string if it represents an ascii value. if 
%%   the codepoint option is present the sequence is converted and inserted as long
%%   as it represents a valid 16 bit integer value (this is where json's spec gets
%%   insane). any other option and the sequence is converted back to an erlang string
%%   and appended to the string in place.
    
escaped_unicode(<<D/utf8, Rest/binary>>, Stack, Callbacks, Opts, String, [C, B, A]) ->
    X = erlang:list_to_integer([A, B, C, D], 16),
    case Opts#opts.escaped_unicode of
        ascii when X < 16#0080 ->
            string(Rest, Stack, Callbacks, Opts, [X] ++ String)
        ; codepoint ->
            string(Rest, Stack, Callbacks, Opts, [X] ++ String)
        ; none ->
            string(Rest, Stack, Callbacks, Opts, [?rsolidus, $u, A, B, C, D] ++ String)
    end;
escaped_unicode(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, String, Acc) when ?is_hex(S) ->
    escaped_unicode(Rest, Stack, Callbacks, Opts, String, [S] ++ Acc);
escaped_unicode(<<>>, Stack, Callbacks, Opts, String, Acc) ->
    fun(Stream) -> escaped_unicode(Stream, Stack, Callbacks, Opts, String, Acc) end.
    
    
%% like strings, numbers are collected in an intermediate accumulator before
%%   being emitted to the callback handler. no processing of numbers is done in
%%   process, it's left for the user, though there are convenience functions to
%%   convert them into erlang floats/integers in jsx_utils.erl.

%% TODO: actually write that jsx_utils.erl module mentioned above...
    
negative(<<"0"/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    zero(Rest, Stack, Callbacks, Opts, "0" ++ Acc);
negative(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when ?is_nonzero(S) ->
    integer(Rest, Stack, Callbacks, Opts, [S] ++ Acc);
negative(<<>>, Stack, Callbacks, Opts, Acc) ->
    fun(Stream) -> negative(Stream, Stack, Callbacks, Opts, Acc) end.
    
    
zero(<<?end_object/utf8, Rest/binary>>, [object|Stack], Callbacks, Opts, Acc) ->
    maybe_done(Rest, Stack, callback(end_object, callback({number, lists:reverse(Acc)}, Callbacks)), Opts);
zero(<<?end_array/utf8, Rest/binary>>, [array|Stack], Callbacks, Opts, Acc) ->
    maybe_done(Rest, Stack, callback(end_array, callback({number, lists:reverse(Acc)}, Callbacks)), Opts);
zero(<<?comma/utf8, Rest/binary>>, [object|Stack], Callbacks, Opts, Acc) ->
    key(Rest, [key|Stack], callback({number, lists:reverse(Acc)}, Callbacks), Opts);
zero(<<?comma/utf8, Rest/binary>>, [array|_] = Stack, Callbacks, Opts, Acc) ->
    value(Rest, Stack, callback({number, lists:reverse(Acc)}, Callbacks), Opts);
zero(<<?decimalpoint/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    fraction(Rest, Stack, Callbacks, Opts, [?decimalpoint] ++ Acc);
zero(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when ?is_whitespace(S) ->
    maybe_done(Rest, Stack, callback({number, lists:reverse(Acc)}, Callbacks), Opts);
zero(<<?solidus/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when Opts#opts.comments == true ->
    maybe_comment(Rest, fun(Resume) -> zero(Resume, Stack, Callbacks, Opts, Acc) end);
zero(<<>>, Stack, Callbacks, Opts, Acc) ->
    fun(Stream) -> zero(Stream, Stack, Callbacks, Opts, Acc) end.
    
    
integer(<<?end_object/utf8, Rest/binary>>, [object|Stack], Callbacks, Opts, Acc) ->
    maybe_done(Rest, Stack, callback(end_object, callback({number, lists:reverse(Acc)}, Callbacks)), Opts);
integer(<<?end_array/utf8, Rest/binary>>, [array|Stack], Callbacks, Opts, Acc) ->
    maybe_done(Rest, Stack, callback(end_array, callback({number, lists:reverse(Acc)}, Callbacks)), Opts);
integer(<<?comma/utf8, Rest/binary>>, [object|Stack], Callbacks, Opts, Acc) ->
    key(Rest, [key|Stack], callback({number, lists:reverse(Acc)}, Callbacks), Opts);
integer(<<?comma/utf8, Rest/binary>>, [array|_] = Stack, Callbacks, Opts, Acc) ->
    value(Rest, Stack, callback({number, lists:reverse(Acc)}, Callbacks), Opts);
integer(<<?decimalpoint/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    fraction(Rest, Stack, Callbacks, Opts, [?decimalpoint] ++ Acc);
integer(<<?zero/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    integer(Rest, Stack, Callbacks, Opts, [?zero] ++ Acc);
integer(<<"e"/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    e(Rest, Stack, Callbacks, Opts, "e" ++ Acc);
integer(<<"E"/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    e(Rest, Stack, Callbacks, Opts, "e" ++ Acc);
integer(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when ?is_nonzero(S) ->
    integer(Rest, Stack, Callbacks, Opts, [S] ++ Acc);
integer(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when ?is_whitespace(S) ->
    maybe_done(Rest, Stack, callback({number, lists:reverse(Acc)}, Callbacks), Opts);
integer(<<?solidus/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when Opts#opts.comments == true ->
    maybe_comment(Rest, fun(Resume) -> integer(Resume, Stack, Callbacks, Opts, Acc) end);
integer(<<>>, Stack, Callbacks, Opts, Acc) ->
    fun(Stream) -> integer(Stream, Stack, Callbacks, Opts, Acc) end.
    

fraction(<<?end_object/utf8, Rest/binary>>, [object|Stack], Callbacks, Opts, Acc) ->
    maybe_done(Rest, Stack, callback(end_object, callback({number, lists:reverse(Acc)}, Callbacks)), Opts);
fraction(<<?end_array/utf8, Rest/binary>>, [array|Stack], Callbacks, Opts, Acc) ->
    maybe_done(Rest, Stack, callback(end_array, callback({number, lists:reverse(Acc)}, Callbacks)), Opts);
fraction(<<?comma/utf8, Rest/binary>>, [object|Stack], Callbacks, Opts, Acc) ->
    key(Rest, [key|Stack], callback({number, lists:reverse(Acc)}, Callbacks), Opts);
fraction(<<?comma/utf8, Rest/binary>>, [array|_] = Stack, Callbacks, Opts, Acc) ->
    value(Rest, Stack, callback({number, lists:reverse(Acc)}, Callbacks), Opts);
fraction(<<?zero/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    fraction(Rest, Stack, Callbacks, Opts, [?zero] ++ Acc);
fraction(<<"e"/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    e(Rest, Stack, Callbacks, Opts, "e" ++ Acc);
fraction(<<"E"/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    e(Rest, Stack, Callbacks, Opts, "e" ++ Acc);
fraction(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when ?is_nonzero(S) ->
    fraction(Rest, Stack, Callbacks, Opts, [S] ++ Acc);
fraction(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when ?is_whitespace(S) ->
    maybe_done(Rest, Stack, callback({number, lists:reverse(Acc)}, Callbacks), Opts);
fraction(<<?solidus/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when Opts#opts.comments == true ->
    maybe_comment(Rest, fun(Resume) -> fraction(Resume, Stack, Callbacks, Opts, Acc) end);
fraction(<<>>, Stack, Callbacks, Opts, Acc) ->
    fun(Stream) -> fraction(Stream, Stack, Callbacks, Opts, Acc) end.
    
    
e(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when S =:= ?positive; S =:= ?negative ->
    ex(Rest, Stack, Callbacks, Opts, [S] ++ Acc);
e(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when S =:= ?zero; ?is_nonzero(S) ->
    exp(Rest, Stack, Callbacks, Opts, [S] ++ Acc);
e(<<>>, Stack, Callbacks, Opts, Acc) ->
    fun(Stream) -> e(Stream, Stack, Callbacks, Opts, Acc) end.
  
    
ex(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when S =:= ?zero; ?is_nonzero(S) ->
    exp(Rest, Stack, Callbacks, Opts, [S] ++ Acc);
ex(<<>>, Stack, Callbacks, Opts, Acc) ->
    fun(Stream) -> ex(Stream, Stack, Callbacks, Opts, Acc) end.
    

exp(<<?end_object/utf8, Rest/binary>>, [object|Stack], Callbacks, Opts, Acc) ->
    maybe_done(Rest, Stack, callback(end_object, callback({number, lists:reverse(Acc)}, Callbacks)), Opts);
exp(<<?end_array/utf8, Rest/binary>>, [array|Stack], Callbacks, Opts, Acc) ->
    maybe_done(Rest, Stack, callback(end_array, callback({number, lists:reverse(Acc)}, Callbacks)), Opts);
exp(<<?comma/utf8, Rest/binary>>, [object|Stack], Callbacks, Opts, Acc) ->
    key(Rest, [key|Stack], callback({number, lists:reverse(Acc)}, Callbacks), Opts);
exp(<<?comma/utf8, Rest/binary>>, [array|_] = Stack, Callbacks, Opts, Acc) ->
    value(Rest, Stack, callback({number, lists:reverse(Acc)}, Callbacks), Opts);
exp(<<?zero/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) ->
    exp(Rest, Stack, Callbacks, Opts, [?zero] ++ Acc);
exp(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when ?is_nonzero(S) ->
    exp(Rest, Stack, Callbacks, Opts, [S] ++ Acc);
exp(<<S/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when ?is_whitespace(S) ->
    maybe_done(Rest, Stack, callback({number, lists:reverse(Acc)}, Callbacks), Opts);
exp(<<?rsolidus/utf8, Rest/binary>>, Stack, Callbacks, Opts, Acc) when Opts#opts.comments == true ->
    maybe_comment(Rest, fun(Resume) -> exp(Resume, Stack, Callbacks, Opts, Acc) end);
exp(<<>>, Stack, Callbacks, Opts, Acc) ->
    fun(Stream) -> exp(Stream, Stack, Callbacks, Opts, Acc) end.
    
    
tr(<<"r"/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    tru(Rest, Stack, Callbacks, Opts);
tr(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> tr(Stream, Stack, Callbacks, Opts) end.
    
    
tru(<<"u"/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    true(Rest, Stack, Callbacks, Opts);
tru(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> tru(Stream, Stack, Callbacks, Opts) end.

    
true(<<"e"/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    maybe_done(Rest, Stack, callback({literal, true}, Callbacks), Opts);
true(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> true(Stream, Stack, Callbacks, Opts) end.
    
    
fa(<<"a"/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    fal(Rest, Stack, Callbacks, Opts);
fa(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> fa(Stream, Stack, Callbacks, Opts) end.


fal(<<"l"/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    fals(Rest, Stack, Callbacks, Opts);
fal(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> fal(Stream, Stack, Callbacks, Opts) end.


fals(<<"s"/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    false(Rest, Stack, Callbacks, Opts);
fals(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> fals(Stream, Stack, Callbacks, Opts) end.
    
    
false(<<"e"/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    maybe_done(Rest, Stack, callback({literal, false}, Callbacks), Opts);
false(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> false(Stream, Stack, Callbacks, Opts) end.
    

nu(<<"u"/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    nul(Rest, Stack, Callbacks, Opts);
nu(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> nu(Stream, Stack, Callbacks, Opts) end.


nul(<<"l"/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    null(Rest, Stack, Callbacks, Opts);
nul(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> nul(Stream, Stack, Callbacks, Opts) end.


null(<<"l"/utf8, Rest/binary>>, Stack, Callbacks, Opts) ->
    maybe_done(Rest, Stack, callback({literal, null}, Callbacks), Opts);
null(<<>>, Stack, Callbacks, Opts) ->
    fun(Stream) -> null(Stream, Stack, Callbacks, Opts) end.    
    
    
%% comments are c style, /* blah blah */ and are STRONGLY discouraged. any unicode
%%   character is valid in a comment, except, obviously the */ sequence which ends
%%   the comment. they're implemented as a closure called when the comment ends that
%%   returns execution to the point where the comment began. comments are not 
%%   recorded in any way, simply parsed.    
    
maybe_comment(<<?star/utf8, Rest/binary>>, Resume) ->
    comment(Rest, Resume);
maybe_comment(<<>>, Resume) ->
    fun(Stream) -> maybe_comment(Stream, Resume) end.
    
    
comment(<<?star/utf8, Rest/binary>>, Resume) ->
    maybe_comment_done(Rest, Resume);
comment(<<_/utf8, Rest/binary>>, Resume) ->
    comment(Rest, Resume);
comment(<<>>, Resume) ->
    fun(Stream) -> comment(Stream, Resume) end.
    
    
maybe_comment_done(<<?solidus/utf8, Rest/binary>>, Resume) ->
    Resume(Rest);
maybe_comment_done(<<>>, Resume) ->
    fun(Stream) -> maybe_comment_done(Stream, Resume) end.

    

        


