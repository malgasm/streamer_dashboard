defmodule SoundboardWeb.TwitchIncomingChatTest do
  use ExUnit.Case, async: false
  import Mock

  setup_with_mocks([
    {SoundboardWeb.ProcessHelper, [], [send_process: fn(_,_) -> {:ok} end]},
  ]) do
    :ok
  end

  defp sub_arg, do: "malgasm!malgasm@malgasm.tmi.twitch.tv PRIVMSG #malgasm :123"

  test "handle_tagged_message handles subscription messages" do
    sub_message = "@badge-info=subscriber/6;badges=moderator/1,subscriber/6,overwatch-league-insider_2019A/1;color=#FF0000;display-name=Shroud;emotes=;flags=;id=1399c486-1376-48f1-8489-f313af16d507;login=Shroud;mod=1;msg-id=sub;msg-param-cumulative-months=6;msg-param-months=0;msg-param-should-share-streak=1;msg-param-streak-months=6;msg-param-sub-plan-name=Channel\\sSubscription\\s(malgasm);msg-param-sub-plan=1000;room-id=158826258;subscriber=1;system-msg=Shroud\\ssubscribed\\sat\\sTier\\s1.\\sThey've\\ssubscribed\\sfor\\s6\\smonths,\\scurrently\\son\\sa\\s6\\smonth\\sstreak!;tmi-sent-ts=1568082484294;user-id=129228929;user-type=mod"

    SoundboardWeb.TwitchIncomingChatHandler.handle_tagged_message("", sub_message, sub_arg)
    assert_called SoundboardWeb.ProcessHelper.send_process(SoundboardWeb.SpecialEventHandler, {:sub, %{
      bits: nil, gift_sub_quantity: nil, gift_sub_recipient: nil, sub_months: "6", sub_streak: "6", sub_tier: "1000", username: "Shroud"
    }})
  end

  test "handle_tagged_message handles resub messages" do
    sub_message = "@badge-info=subscriber/6;badges=moderator/1,subscriber/6,overwatch-league-insider_2019A/1;color=#FF0000;display-name=Shroud;emotes=;flags=;id=1399c486-1376-48f1-8489-f313af16d507;login=Shroud;mod=1;msg-id=resub;msg-param-cumulative-months=6;msg-param-months=0;msg-param-should-share-streak=1;msg-param-streak-months=6;msg-param-sub-plan-name=Channel\\sSubscription\\s(malgasm);msg-param-sub-plan=1000;room-id=158826258;subscriber=1;system-msg=Shroud\\ssubscribed\\sat\\sTier\\s1.\\sThey've\\ssubscribed\\sfor\\s6\\smonths,\\scurrently\\son\\sa\\s6\\smonth\\sstreak!;tmi-sent-ts=1568082484294;user-id=129228929;user-type=mod"

    SoundboardWeb.TwitchIncomingChatHandler.handle_tagged_message("", sub_message, sub_arg)
    assert_called SoundboardWeb.ProcessHelper.send_process(SoundboardWeb.SpecialEventHandler, {:resub, %{
      bits: nil, gift_sub_quantity: nil, gift_sub_recipient: nil, sub_months: "6", sub_streak: "6", sub_tier: "1000", username: "Shroud"
    }})
  end

  test "handle_tagged_message handles gift subs" do
    sub_message = "@badge-info=subscriber/12;badges=broadcaster/1,subscriber/12,sub-gifter/1;color=#22DD13;display-name=malgasm;emotes=;flags=;id=281ce9a4-e4eb-4a63-a58e-8503b33a1b69;login=malgasm;mod=0;msg-id=subgift;msg-param-months=1;msg-param-origin-id=da\\s39\\sa3\\see\\s5e\\s6b\\s4b\\s0d\\s32\\s55\\sbf\\sef\\s95\\s60\\s18\\s90\\saf\\sd8\\s07\\s09;msg-param-recipient-display-name=phnxdwn_n;msg-param-recipient-id=81307341;msg-param-recipient-user-name=phnxdwn_n;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(malgasm);msg-param-sub-plan=1000;room-id=158826258;subscriber=1;system-msg=malgasm\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sphnxdwn_n!;tmi-sent-ts=1568084845220;user-id=158826258;user-type="

    SoundboardWeb.TwitchIncomingChatHandler.handle_tagged_message("", sub_message, sub_arg)
    assert_called SoundboardWeb.ProcessHelper.send_process(SoundboardWeb.SpecialEventHandler, {:subgift, %{bits: nil, gift_sub_quantity: nil, gift_sub_recipient: "phnxdwn_n", sub_months: "1", sub_streak: nil, sub_tier: "1000", username: "malgasm"}})
  end

  test "handle_tagged_message handles anonymous gift subs" do
    sub_message = "@badge-info=subscriber/6;badges=moderator/1,subscriber/6,overwatch-league-insider_2019A/1;color=#FF0000;display-name=Shroud;emotes=;flags=;id=75cf0038-ab1e-4842-82ce-b35f214f8eca;login=Shroud;mod=1;msg-id=submysterygift;msg-param-mass-gift-count=5;msg-param-origin-id=69\s46\s38\sfc\s9b\see\s7f\sb5\s3d\s1b\s81\s8d\s58\s91\s02\s21\s59\s86\s1b\s5d;msg-param-sender-count=45;msg-param-sub-plan=1000;room-id=158826258;subscriber=1;system-msg=Shroud\sis\sgifting\s5\sTier\s1\sSubs\sto\smalgasm's\scommunity!\sThey've\sgifted\sa\stotal\sof\s45\sin\sthe\schannel!;tmi-sent-ts=1568090502470;user-id=129228929;user-type=mod"

    SoundboardWeb.TwitchIncomingChatHandler.handle_tagged_message("", sub_message, sub_arg)
    assert_called SoundboardWeb.ProcessHelper.send_process(SoundboardWeb.SpecialEventHandler, {:submysterygift, %{bits: nil, gift_sub_quantity: "5", gift_sub_recipient: nil, sub_months: nil, sub_streak: nil, sub_tier: "1000", username: "Shroud"}})
  end

  test "handle_tagged_message handles resubs without a streak" do
    sub_message = "@badge-info=subscriber/6;badges=moderator/1,subscriber/6,overwatch-league-insider_2019A/1;color=#FF0000;display-name=Shroud;emotes=;flags=;id=1399c486-1376-48f1-8489-f313af16d507;login=Shroud;mod=1;msg-id=resub;msg-param-cumulative-months=6;msg-param-months=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(malgasm);msg-param-sub-plan=1000;room-id=158826258;subscriber=1;system-msg=Shroud\\ssubscribed\\sat\\sTier\\s1.\\sThey've\\ssubscribed\\sfor\\s6\\smonths,\\scurrently\\son\\sa\\s6\\smonth\\sstreak!;tmi-sent-ts=1568082484294;user-id=129228929;user-type=mod"

    SoundboardWeb.TwitchIncomingChatHandler.handle_tagged_message("", sub_message, sub_arg)
    assert_called SoundboardWeb.ProcessHelper.send_process(SoundboardWeb.SpecialEventHandler, {:resub, %{bits: nil, gift_sub_quantity: nil, gift_sub_recipient: nil, sub_months: "6", sub_streak: nil, sub_tier: "1000", username: "Shroud"}})
  end
end
