%% -*- mode: erlang; tab-width: 4; indent-tabs-mode: 1; st-rulers: [70] -*-
%% vim: ts=4 sw=4 ft=erlang noet
-module(jose_jwe_zip_props).

-include_lib("triq/include/triq.hrl").

-compile(export_all).

binary_map() ->
	?LET(List,
		list({binary(), binary()}),
		maps:from_list(List)).

enc() ->
	oneof([
		<<"A128GCM">>,
		<<"A192GCM">>,
		<<"A256GCM">>
	]).

jwk_jwe_maps() ->
	?LET(ENC,
		enc(),
		begin
			FakeJWEMap = #{ <<"alg">> => <<"RSA1_5">>, <<"enc">> => ENC },
			FakeJWE = jose_jwe:from_map(FakeJWEMap),
			Key = jose_jwe:next_cek(undefined, FakeJWE),
			JWKMap = #{
				<<"kty">> => <<"oct">>,
				<<"k">> => base64url:encode(Key)
			},
			JWEMap = #{
				<<"alg">> => <<"dir">>,
				<<"enc">> => ENC,
				<<"zip">> => <<"DEF">>
			},
			{Key, JWKMap, JWEMap}
		end).

jwk_jwe_gen() ->
	?LET({Key, JWKMap, JWEMap},
		jwk_jwe_maps(),
		{Key, jose_jwk:from_map(JWKMap), jose_jwe:from_map(JWEMap)}).

prop_from_map_and_to_map() ->
	?FORALL(JWEMap,
		?LET({{_Key, _JWKMap, JWEMap}, Extras},
			{jwk_jwe_maps(), binary_map()},
			maps:merge(Extras, JWEMap)),
		begin
			JWE = jose_jwe:from_map(JWEMap),
			JWEMap =:= element(2, jose_jwe:to_map(JWE))
		end).

prop_block_encrypt_and_block_decrypt() ->
	?FORALL({CEK, IV, JWK, JWE, PlainText},
		?LET({CEK, JWK, JWE},
			jwk_jwe_gen(),
			{CEK, jose_jwe:next_iv(JWE), JWK, JWE, binary()}),
		begin
			Encrypted = jose_jwe:block_encrypt(JWK, PlainText, CEK, IV, JWE),
			CompactEncrypted = jose_jwe:compact(Encrypted),
			PlainText =:= element(1, jose_jwe:block_decrypt(JWK, CompactEncrypted))
		end).

prop_compress_and_uncompress() ->
	?FORALL({{_CEK, _JWK, JWE}, PlainText},
		{jwk_jwe_gen(), binary()},
		begin
			CipherText = jose_jwe:compress(PlainText, JWE),
			CipherText =/= PlainText andalso PlainText =:= jose_jwe:uncompress(CipherText, JWE)
		end).